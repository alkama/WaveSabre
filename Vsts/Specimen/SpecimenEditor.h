#ifndef __SPECIMENEDITOR_H__
#define __SPECIMENEDITOR_H__

#include <WaveSabreVstLib.h>
using namespace WaveSabreVstLib;

#include <WaveSabreCore.h>
using namespace WaveSabreCore;

class SpecimenEditor : public VstEditor
{
public:
	SpecimenEditor(AudioEffect *audioEffect);
	virtual ~SpecimenEditor();

	virtual void Open();

	virtual void setParameter(VstInt32 index, float value);

private:
#ifndef LGCM_MAC
	static BOOL __stdcall driverEnumCallback(HACMDRIVERID driverId, DWORD dwInstance, DWORD fdwSupport);
	static BOOL __stdcall formatEnumCallback(HACMDRIVERID driverId, LPACMFORMATDETAILS formatDetails, DWORD_PTR dwInstance, DWORD fdwSupport);

	static HACMDRIVERID driverId;
#endif
	static WAVEFORMATEX *foundWaveFormat;

	bool pressedTheFuck;

#ifndef LGCM_MAC
	CFileSelector *fileSelector;
#endif

	Specimen *specimen;
};

#endif
