/*
 *  AudioDispatch.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 7/21/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "SoundEffect.h"
#import <vector>


namespace Dog3D
{
	
	class AudioDispatch
	{
		
		
		static AudioDispatch *sInstance;
		
		std::vector<SoundEffect *> mSoundEffects;
		
		AudioDispatch();
		~AudioDispatch();
		
		bool mAudioIsOn;
		
	public:
		
		enum SoundEffects
		{
			Boom1 = 0, 
			Boom2 = 1
		};
		
		static AudioDispatch *Instance(){ return sInstance;}
		
		static void Initialize()
		{
			sInstance = new AudioDispatch();
		}
		
		static void ShutDown()
		{
			delete sInstance;
			sInstance = NULL;
		}
		
		void PlaySound(int idx);
		
		inline void SetAudioOn(bool state)
		{
			mAudioIsOn = state;
		}
		
	};

}