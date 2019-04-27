#include "WSiPlug.h"
#ifndef PLUG_SC_CHANS
  #define PLUG_SC_CHANS 0
#endif

#define PUBLIC_NAME PLUG_NAME
#include "IControl.h"

WSiPlug::WSiPlug(WaveSabreCore::Device *device, int nParams, int nPresets, IPlugInstanceInfo instanceInfo)
: IPlug(instanceInfo, nParams, PLUG_CHANNEL_IO, nPresets,
        PUBLIC_NAME, "", PLUG_MFR, PLUG_VER, PLUG_UNIQUE_ID, PLUG_MFR_ID,
        PLUG_LATENCY, PLUG_DOES_MIDI, PLUG_DOES_STATE_CHUNKS, PLUG_IS_INST, PLUG_SC_CHANS),
  device(device), t_ins{nullptr}, t_outs{nullptr}, oldFramesCount(-1)
{
  TRACE;
  WaveSabreCore::Helpers::Init();
}

WSiPlug::~WSiPlug() {
  for (int i=0; i<2; i++) {
    if(t_ins[i]) { free(t_ins[i]); t_ins[i] = nullptr; }
    if(t_outs[i]) { free(t_outs[i]); t_outs[i] = nullptr; }
  }
  if(device) delete device;
}

void WSiPlug::ProcessDoubleReplacing(double** inputs, double** outputs, int nFrames)
{
  // Mutex is already locked for us.
  if(!device) return;
  
  // init our temp buffers to migrate from double (WDL) to floats (WaveSabre) and vice versa
  for (int i=0; i<2; i++) {
    if(oldFramesCount != nFrames) {
      if(t_ins[i]) { free(t_ins[i]); t_ins[i] = nullptr; }
      if(t_outs[i]) { free(t_outs[i]); t_outs[i] = nullptr; }
      t_ins[i] = (float *)malloc(nFrames * sizeof(float));
      t_outs[i] = (float *)malloc(nFrames * sizeof(float));
      oldFramesCount = nFrames;
    }
    if(!t_ins[i]) { t_ins[i] = (float *)malloc(nFrames * sizeof(float)); }
    if(!t_outs[i]) { t_outs[i] = (float *)malloc(nFrames * sizeof(float)); }
  }
  
  device->SetTempo((int)this->GetTempo());

  for (int s = 0; s < nFrames; ++s)
  {
    t_ins[0][s] = inputs[0][s];
    t_ins[1][s] = inputs[1][s];
  }

  device->Run(this->GetSamplePos() / this->GetSampleRate(), t_ins, t_outs, nFrames);

  for (int s = 0; s < nFrames; ++s)
  {
    outputs[0][s] = ((float**)t_outs)[0][s];
    outputs[1][s] = ((float**)t_outs)[1][s];
  }
}

void WSiPlug::Reset()
{
  TRACE;
  IMutexLock lock(this);
  
  if(device) {
    device->SetSampleRate(this->GetSampleRate());
  }
}

void WSiPlug::OnParamChange(int paramIdx)
{
  IMutexLock lock(this);
  
  if(device && (paramIdx < NParams())) {
    device->SetParam(paramIdx, (float)(this->GetParam(paramIdx)->Value() / 100.));
  }
  
  GetGUI()->SetAllControlsDirty();
}

void WSiPlug::DeclareParam(int paramIdx, const char* name)
{
  this->GetParam(paramIdx)->InitDouble(name, device->GetParam(paramIdx) * 100., 0., 100.0, 0.01, "%");
}

bool WSiPlug::SerializeState(ByteChunk* pChunk)
{
  TRACE;
  IMutexLock lock(this);
  bool savedOK = true;
  int n = this->NParams();
  for (int i=0; i<n && savedOK; ++i)
  {
    IParam* pParam = this->GetParam(i);
    double pv = pParam->Value();
    float dv = device->GetParam(i);
    Trace(TRACELOC, "%d %s %f => %f", i, pParam->GetNameForHost(), pv, dv);
    savedOK &= (pChunk->Put(&dv) > 0);
  }
  return savedOK;
}

int WSiPlug::UnserializeState(ByteChunk* pChunk, int startPos)
{
  TRACE;
  IMutexLock lock(this);
  int pos=startPos;
  int n = this->NParams();
  for (int i=0; i<n && pos>=0; ++i)
  {
    IParam* pParam = this->GetParam(i);
    float dv = 0.0f;
    pos = pChunk->Get(&dv, pos);
    device->SetParam(i, dv);
    pParam->Set(dv * 100.);
    Trace(TRACELOC, "%d %s %f => %f", i, pParam->GetNameForHost(), device->GetParam(i), pParam->Value());
  }
  
  if(GetGUI()) {
    GetGUI()->SetAllControlsDirty();
  }
  return pos;
}


void WSiPlug::AddKnob(IGraphics* pGraphics, IBitmap* pBitmap, int paramIdx, const char* name, int x, int y)
{
  IText textProps(12, &COLOR_GRAY, (char*)"Arial", IText::kStyleNormal, IText::kAlignCenter, 0, IText::kQualityDefault);
  
  pGraphics->AttachControl(new IKnobMultiControl(this, x, y, paramIdx, pBitmap));
  pGraphics->AttachControl(new ICaptionControl(this, IRECT(x-7, y+55, x+66, y+67), paramIdx, &textProps, true));
  pGraphics->AttachControl(new ITextControl(this, IRECT(x-7, y+70, x+66, y+90), &textProps, name));
}
