#include "Crusher.h"
#include "IPlug_include_in_plug_src.h"
#include "IControl.h"
#include "resource.h"

const int kNumPrograms = 1;

Crusher::Crusher(IPlugInstanceInfo instanceInfo)
:	WSiPlug(new WaveSabreCore::Crusher(), (int)WaveSabreCore::Crusher::ParamIndices::NumParams, kNumPrograms, instanceInfo)
{
  TRACE;

  // Declare all parameters
  DeclareParam((int)WaveSabreCore::Crusher::ParamIndices::Vertical, "Vert");
  DeclareParam((int)WaveSabreCore::Crusher::ParamIndices::Horizontal, "Hori");
  DeclareParam((int)WaveSabreCore::Crusher::ParamIndices::DryWet, "Dry/Wet");

  // Create the GUI
  IGraphics* pGraphics = MakeGraphics(this, GUI_WIDTH, GUI_HEIGHT);
  {
    pGraphics->AttachBackground(BG_ID, BG_FN);

    IBitmap knob = pGraphics->LoadIBitmap(KNOB_ID, KNOB_FN, KNOB_FRAMES);
    
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Crusher::ParamIndices::Vertical, "Vertical", 57, 52);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Crusher::ParamIndices::Horizontal, "Horizontal", 172, 52);
    AddKnob(pGraphics, &knob, (int)WaveSabreCore::Crusher::ParamIndices::DryWet, "Dry/Wet", 287, 52);
  }
  AttachGraphics(pGraphics);

  // Generate presets
  MakeDefaultPreset((char *) "Default", kNumPrograms);
}
