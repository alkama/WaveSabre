#include "Echo.h"
#include "IPlug_include_in_plug_src.h"
#include "IControl.h"
#include "resource.h"

const int kNumPrograms = 1;

Echo::Echo(IPlugInstanceInfo instanceInfo)
:	WSiPlug(new WaveSabreCore::Echo(), (int)WaveSabreCore::Echo::ParamIndices::NumParams, kNumPrograms, instanceInfo)
{
  TRACE;

  // Declare all parameters
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::LeftDelayCoarse, "LDly Crs");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::LeftDelayFine, "LDly Fin");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::RightDelayCoarse, "RDly Crs");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::RightDelayFine, "RDly Fin");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::LowCutFreq, "LC Freq");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::HighCutFreq, "HC Freq");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::Feedback, "Feedback");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::Cross, "Cross");
  DeclareParam((int)WaveSabreCore::Echo::ParamIndices::DryWet, "Dry/Wet");

  // Create the GUI
  IGraphics* pGraphics = MakeGraphics(this, GUI_WIDTH, GUI_HEIGHT);
  {
    pGraphics->AttachBackground(BG_ID, BG_FN);

    IBitmap knob = pGraphics->LoadIBitmap(KNOB_ID, KNOB_FN, KNOB_FRAMES);
    
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::LeftDelayCoarse, "Left Coarse", 20, 36);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::LeftDelayFine, "Left Fine", 95, 36);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::Feedback, "Feedback", 170, 36);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::Cross, "Cross", 245, 36);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::DryWet, "Dry/Wet", 320, 86);
    
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::RightDelayCoarse, "Right Coarse", 20, 136);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::RightDelayFine, "Right Fine", 95, 136);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::LowCutFreq, "LC Freq", 170, 136);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Echo::ParamIndices::HighCutFreq, "HC Freq", 245, 136);
  }
  AttachGraphics(pGraphics);

  // Generate presets
  MakeDefaultPreset((char *) "Default", kNumPrograms);
}
