#import "Live2D-binding.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SceneKit/SceneKit.h>
#import "CubismModelSettingJson.hpp"
#import "Model/CubismUserModel.hpp"
#import "Rendering/OpenGL/CubismRenderer_OpenGLES2.hpp"
#import "Id/CubismIdManager.hpp"
#import "CubismPhysics.hpp"

using namespace Live2D::Cubism::Framework;
using namespace Live2D::Cubism::Core;

#pragma mark - Allocator class

class Allocator: public Csm::ICubismAllocator
{
	void* Allocate(const Csm::csmSizeType size) {
		return malloc(size);
	}

	void Deallocate(void* memory) {
		free(memory);
	}

	void* AllocateAligned(const Csm::csmSizeType size, const Csm::csmUint32 alignment) {
		size_t offset, shift, alignedAddress;
		void* allocation;
		void** preamble;

		offset = alignment - 1 + sizeof(void*);

		allocation = Allocate(size + static_cast<csmUint32>(offset));

		alignedAddress = reinterpret_cast<size_t>(allocation) + sizeof(void*);

		shift = alignedAddress % alignment;

		if (shift)
		{
			alignedAddress += (alignment - shift);
		}

		preamble = reinterpret_cast<void**>(alignedAddress);
		preamble[-1] = allocation;

		return reinterpret_cast<void*>(alignedAddress);
	}

	void DeallocateAligned(void* alignedMemory){
		void** preamble;

		preamble = static_cast<void**>(alignedMemory);

		Deallocate(preamble[-1]);
	}
};

#pragma mark - Live2DCubism class

static Allocator _allocator;

@implementation Live2DCubism
+ (void)initL2D {
	Csm::CubismFramework::StartUp(&_allocator, NULL);
	Csm::CubismFramework::Initialize();
}

+ (void)dispose {
	Csm::CubismFramework::Dispose();
}

+ (NSString *)live2DVersion {
	unsigned int version = csmGetVersion();
	unsigned int major = (version >> 24) & 0xff;
	unsigned int minor = (version >> 16) & 0xff;
	unsigned int patch = version & 0xffff;

	return [NSString stringWithFormat:@"v%1$d.%2$d.%3$d", major, minor, patch];
}
@end

#pragma mark - Live2DModelOpenGL class

@interface Live2DModelOpenGL ()

@property (nonatomic, assign) CubismUserModel *userModel;
@property (nonatomic, assign) NSURL *baseUrl;
@property (nonatomic, assign) CubismPhysics *physics;
@property (nonatomic, assign) ICubismModelSetting *modelSetting;

@end

@implementation Live2DModelOpenGL
- (instancetype)initWithJsonPath:(NSString *)jsonPath {
	if (self = [super init]) {
		NSURL *url = [NSURL fileURLWithPath:jsonPath];
		NSData *jsonData = [NSData dataWithContentsOfURL:url];

		_modelSetting = new CubismModelSettingJson((const unsigned char *)[jsonData bytes], (unsigned int)[jsonData length]);
		_baseUrl = [url URLByDeletingLastPathComponent];

		url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetModelFileName()]];

		NSData *data = [NSData dataWithContentsOfURL:url];
		_userModel = new CubismUserModel();
		_userModel->LoadModel((const unsigned char *)[data bytes], (unsigned int)[data length]);
		_userModel->CreateRenderer();
		_userModel->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->Initialize(_userModel->GetModel());

		if (strcmp(_modelSetting->GetPhysicsFileName(), "") != 0)
		{
			NSURL* url = [_baseUrl URLByAppendingPathComponent:[NSString stringWithUTF8String:_modelSetting->GetPhysicsFileName()]];
			NSData *data = [NSData dataWithContentsOfURL:url];
			_physics = CubismPhysics::Create((const unsigned char *)[data bytes], (unsigned int)[data length]);
		}

	}
	return self;
}

- (int)getNumberOfTextures {
	return _modelSetting->GetTextureCount();
}

- (NSString *)getFileNameOfTexture:(int)number {
	NSString* fileName = [NSString stringWithUTF8String:_modelSetting->GetTextureFileName(number)];
	NSURL *url = [NSURL URLWithString:fileName relativeToURL:_baseUrl];
	return [url lastPathComponent];
}

- (void)setTexture:(int)textureNo to:(uint32_t)openGLTextureNo {
	_userModel->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->BindTexture(textureNo, openGLTextureNo);
}

- (void)setPremultipliedAlpha:(bool)enable {
	_userModel->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->IsPremultipliedAlpha(enable);
}

- (float)getCanvasWidth {
	return _userModel->GetModel()->GetCanvasWidth();
}

- (void)setMatrix:(SCNMatrix4)matrix {
	float fMatrix[] = {
		matrix.m11, matrix.m12, matrix.m13, matrix.m14,
		matrix.m21, matrix.m22, matrix.m23, matrix.m24,
		matrix.m31, matrix.m32, matrix.m33, matrix.m34,
		matrix.m41, matrix.m42, matrix.m43, matrix.m44
	};
	const auto cMatrix = new CubismMatrix44();
	cMatrix->SetMatrix(fMatrix);
	_userModel->GetRenderer<Live2D::Cubism::Framework::Rendering::CubismRenderer_OpenGLES2>()->SetMvpMatrix(cMatrix);
}

- (void)setParam:(NSString *)paramId value:(Float32)value {
	// example: use `ParamAngleY` to find the cid`ParamAngleY`
	const CubismId* cid = CubismFramework::GetIdManager()->GetId((const char*)[paramId UTF8String]);
//    int a = _userModel->GetModel()->GetParameterIndex(cid);
//	  printf("%d, setParam(): cid %s\n", a, cid->GetString().GetRawString() );
	_userModel->GetModel()->SetParameterValue(cid, value);
}

- (void)yxjtest {
	int partCount = _userModel->GetModel()->GetPartCount();
	int parameterCount = _userModel->GetModel()->GetParameterCount();
	printf("partCount = %d, parameterCount = %d\n", partCount, parameterCount);

	for (int i = 0; i <= parameterCount - 1; i++) {
		float maximumValue = _userModel->GetModel()->GetParameterMaximumValue(i);
		float minimumValue = _userModel->GetModel()->GetParameterMinimumValue(i);
		float defaultValue = _userModel->GetModel()->GetParameterDefaultValue(i);
		printf("(%.2f, %.2f, %.2f)\n",minimumValue, defaultValue, maximumValue);
	}

}

- (void)setPartsOpacity:(NSString *)paramId opacity:(Float32)value {
	const auto cid = CubismFramework::GetIdManager()->GetId((const char*)[paramId UTF8String]);
	_userModel->GetModel()->SetPartOpacity(cid, value);
}

- (void)updatePhysics:(Float32)delta {
	_physics->Evaluate(_userModel->GetModel(), delta);
}

- (void)update {
	_userModel->GetModel()->Update();
}

- (void)draw {
	_userModel->GetRenderer<Live2D::Cubism::Framework::Rendering::CubismRenderer_OpenGLES2>()->DrawModel();
}
@end
