#ifndef __WSIPLUG_H__
#define __WSIPLUG_H__

#include "IPlug_include_in_plug_hdr.h"
#include <WaveSabreCore.h>

class WSiPlug : public IPlug
{
public:
  WSiPlug(WaveSabreCore::Device *device, int nParams, int nPresets, IPlugInstanceInfo instanceInfo);
  virtual ~WSiPlug();
  
  virtual void Reset();
  virtual void OnParamChange(int paramIdx);
  virtual void ProcessDoubleReplacing(double** inputs, double** outputs, int nFrames);

  virtual bool SerializeState(ByteChunk* pChunk);
  virtual int UnserializeState(ByteChunk* pChunk, int startPos);
  
  void DeclareParam(int paramIdx, const char* name);
  
  void AddKnob(IGraphics* pGraphics, IBitmap* pBitmap, int paramIdx, const char* name, int x, int y);
  
protected:
  WaveSabreCore::Device *device;
  float* t_ins[2];
  float* t_outs[2];
  int oldFramesCount;
};

#endif
