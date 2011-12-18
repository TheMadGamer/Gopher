import maya.cmds as cmds

tab = '\t'

#write level contents
tab2 = '\t\t'
tab3 = '\t\t\t'

def export():

	fileName = cmds.file( sceneName=True, query=True )

	fileRoot = fileName.split('/')
	fileRoot = fileRoot[len(fileRoot)-1]

	exportName = fileRoot.split('.')[0]
	exportName = exportName + '.plist'

	print "Exporting " + exportName

	exportPath = 'C:\\Users\\Tony\\Documents\\My Dropbox\\Gopher\\Levels\\'
	
	exportSceneToXML(exportPath + exportName)

	print "Done"
	
def exportSceneToXML(fileName):
	
	outFile = open(fileName,'w')

	#write header
	outFile.write('<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n')
	outFile.write('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n')
	outFile.write('<plist version="1.0">\n\n')

	#begin level dictionary
	outFile.write('<dict>\n')
	
	writeLayoutObjects(outFile)
	
	writeLevelControl(outFile)
	
	writeGeneratedObjects(outFile)
	
	#end level dict
	outFile.write('</dict>\n')
	
	#end plist
	outFile.write('</plist>\n')

	outFile.close()

def writeGeneratedObjects(outFile):
	sel = cmds.ls()
	
	#begin level 0
	outFile.write(tab + '<key>GeneratedObjects</key>\n')

	#level is a dictionary of key -> { type, position, data } 
	outFile.write(tab + '<dict>\n')
	
	for obj in sel:
		# if the object has a game type control
		if(cmds.objExists(obj+ ".GameType")):
			gameType = cmds.getAttr(obj + ".GameType")
			if( gameType == 'Gopher' or gameType == 'Ball'):
				print(gameType  + ' ' + obj)
				
				sx = cmds.getAttr(obj+ '.sx')/2.0
			
				#begin object name
				outFile.write( tab2 + '<key>' + obj + '</key>\n')
				
				#begin object
				outFile.write( tab2 + '<dict>\n')
				
				#write type
				outFile.write( tab3 + '<key>type</key>\n')	

				if(gameType == 'Gopher'):
					outFile.write( tab3 + '<string>gopher</string>\n')
				else:
					outFile.write( tab3 + '<string>ball</string>\n')
				
				#there is no translate info
				
				#write rotate
				outFile.write( tab3 + '<key>radius</key>\n')
				outFile.write( tab3 + '<real>' + str(sx) + '</real>\n')
				
				
				#end object
				outFile.write( tab2+ '</dict>\n')

				
			
	#end level
	outFile.write(tab + '</dict>\n')
	
#write out level control for gameplay manager	
def writeLevelControl(outFile):
	sel = cmds.ls()

	#begin level 0
	outFile.write(tab + '<key>LevelControl</key>\n')

	#level is a dictionary of key -> { type, position, data } 
	outFile.write(tab + '<dict>\n')
	
	for obj in sel:
		# if the object has a game type control
		if(cmds.objExists(obj+ ".GameType")):
			gameType = cmds.getAttr(obj + ".GameType")
			if( gameType == 'LevelControl'):
				print("Level Control")
				numCombos = cmds.getAttr(obj + '.NumCombos')
				numGopherLives = cmds.getAttr(obj + '.NumGopherLives')
				
				outFile.write( tab2 + '<key>numCombos</key>\n')	
				outFile.write( tab2 + '<integer>' + str(int(numCombos)) + '</integer>\n')
				
				outFile.write( tab2 + '<key>numGopherLives</key>\n')	
				outFile.write( tab2 + '<integer>' + str(int(numGopherLives)) +  '</integer>\n')
				
				break
	outFile.write(tab + '</dict>\n')
	
def writeLayoutObjects(outFile):
	sel = cmds.ls()

	wallId = 0
	goalId = 0
	ballId = 0

	#begin level 0
	outFile.write(tab + '<key>LayoutObjects</key>\n')

	#level is a dictionary of key -> { type, position, data } 
	outFile.write(tab + '<dict>\n')
	
	for obj in sel:
		if(cmds.objExists(obj+ ".GameType")):
			gameType = cmds.getAttr(obj + ".GameType")

			## convert from a 48 x 32 scene to 15 x 10
			z = -cmds.getAttr(obj + '.tx') * 10.0 / 16.0
			x = cmds.getAttr(obj + '.tz') * 15.0 / 24.0
			
			x *= 20/15
			
			rotation = cmds.getAttr(obj + '.ry')  *  3.1415965/180.0
			
			sx = cmds.getAttr(obj+ '.sx')/2.0
			sz = cmds.getAttr(obj+ '.sz')/2.0
			
			if(gameType == 'Fence'):
				print(gameType  + ' ' + obj)
				

			elif(gameType == 'Hedge'):
				print(gameType  + ' ' + obj)
		
				#begin object name
				outFile.write( tab2 + '<key>' + obj + '</key>\n')
				
				#begin object
				outFile.write( tab2 + '<dict>\n')
				
				#write type
				outFile.write( tab3 + '<key>type</key>\n')			
				outFile.write( tab3 + '<string>hedge</string>\n')
				
				#write translate
				outFile.write( tab3 + '<key>x</key>\n')
				outFile.write( tab3 + '<real>' + str(x) + '</real>\n')
				
				outFile.write( tab3 + '<key>z</key>\n')
				outFile.write( tab3 + '<real>' + str(z) + '</real>\n')	
				
				#write rotate
				outFile.write( tab3 + '<key>radius</key>\n')
				outFile.write( tab3 + '<real>' + str(sx) + '</real>\n')
				
				
				#end object
				outFile.write( tab2+ '</dict>\n')
				
			elif(gameType == 'Spawn' or gameType == 'Carrot'  ):
				print(gameType  + ' ' + obj)

				#begin object name
				outFile.write( tab2 + '<key>' + obj + '</key>\n')
				
				#begin object
				outFile.write( tab2 + '<dict>\n')
				
				#write type
				outFile.write( tab3 + '<key>type</key>\n')		
				if( gameType == 'Spawn'):	
					outFile.write( tab3 + '<string>spawn</string>\n')
				else:
					outFile.write( tab3 + '<string>target</string>\n')
				
						
				#write translate
				outFile.write( tab3 + '<key>x</key>\n')
				outFile.write( tab3 + '<real>' + str(x) + '</real>\n')
				
				outFile.write( tab3 + '<key>z</key>\n')
				outFile.write( tab3 + '<real>' + str(z) + '</real>\n')	
				
				#write rotate
				outFile.write( tab3 + '<key>radius</key>\n')
				outFile.write( tab3 + '<real>' + str(sx) + '</real>\n')
				
				
				#end object
				outFile.write( tab2+ '</dict>\n')


	#end level
	outFile.write(tab + '</dict>\n')


