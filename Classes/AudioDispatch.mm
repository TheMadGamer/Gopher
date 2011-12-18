/*
 *  AudioDispatch.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 7/21/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "AudioDispatch.h"
#import <vector>

using namespace std;
using namespace Dog3D;

AudioDispatch *AudioDispatch::sInstance;

AudioDispatch::AudioDispatch()
{
	SoundEffect *boom1Effect = 
	[[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Boom1" ofType:@"caf"]];
	
	mSoundEffects.push_back(boom1Effect);
	
	SoundEffect *boom2Effect = 
	[[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Boom2" ofType:@"caf"]];

	mSoundEffects.push_back(boom2Effect);	
	
	mAudioIsOn = true;
	
}

AudioDispatch::~AudioDispatch()
{
	for(std::vector<SoundEffect *>::iterator it = mSoundEffects.begin(); it != mSoundEffects.end(); it++)
	{
		SoundEffect *effect = (*it);
		
		if(effect != nil)
		{
			[effect release];
		}
	}

	mSoundEffects.clear();
}

void AudioDispatch::PlaySound(int idx)
{
	if(mAudioIsOn)
	{
	
		SoundEffect *effect = mSoundEffects[idx];
		if(effect != nil)
		{
			[effect play];
		}
	}
}