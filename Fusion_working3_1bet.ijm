	dir1 = getDirectory("Choose source directory "); 			//request source dir via window
	list = getFileList(dir1);									// read file list
	dir2 = getDirectory("Choose destination directory ");		//request source dir via window

	run("Clear Results");										//to start with an empty results table
	updateResults; 

//start loop:
	for (i=0; i<list.length; i++) {								//set i=0, count nuber of list items, enlagre number +1 each cycle, start cycle at brackets

		path = dir1+list[i];									//path location translated for code

		//ALT://run("Bio-Formats Windowless Importer", "open=[path] autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default"); 	//skips open dialog from bioformats and opens path
		run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");

		title1= getTitle;
		title2 = File.nameWithoutExtension;						//filename as ID (SO NO DOUBLE FINLENAMES!)
//waitForUser("Checkpoint1", "opened");

		run("Stack to Images");									//separate channels
waitForUser("Checkpoint2", "channels separated");

		selectWindow("c:3/3 - "+title2+"");
		close();												//close DIC
//waitForUser("Checkpoint3", "DIC Channel closed");
//duplicate bead-window:
		selectWindow("c:2/3 - "+title2+"");						//select green channel
		rename(""+title2+"-green");
		selectWindow(""+title2+"-green");
		run("Duplicate...", " ");								//duplicate to keep a copy for measureing of bead signal		
//waitForUser("Checkpoint4", "duplicated");
//optimse image, detect particles, add to ROI manager:
		selectWindow(""+title2+"-green-1");						//select copy of green channel
		//run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35 normalize");				//higher contrast supports particle detection
		//run("Apply LUT");
		//run("Sharpen");


waitForUser("Checkpoint5", "Contrast enhanced");
		//run("Close");
		setAutoThreshold("Triangle dark");					//dark Background - important
		setOption("BlackBackground", false);
		run("Convert to Mask");									//generate mask for ROI
	run("Close-");
	run("Close-");
	//run("Watershed");
run("Watershed Irregular Features", "erosion=8 convexity_threshold=1 separator_size=0-200");
waitForUser("Checkpoint5", "Mask ready");
		//ALT://run("Analyze Particles...", "size=1-5 circularity=0.90-1.00 show=[Bare Outlines] exclude add"); //find beads
		run("Analyze Particles...", "size=0.50-3.20 circularity=0.88-1.00 show=[Bare Outlines] exclude include add"); //find single beads
waitForUser("Checkpoint6", "Particles analyzed");
		selectWindow(""+title2+"-green-1");						//close duplicated image
		close();
//saving ROI outlines for troubleshooting:
		selectWindow("Drawing of "+title2+"-green-1");			//select Drawing of ROI s
		saveAs("Gif", dir2+title2+"-green.gif");				//save Drawing of ROI s
		close();												//close Drawing of ROI s
//waitForUser("Checkpoint12", "Drawing saved");

		run("Set Measurements...", "mean display redirect=None decimal=2");	//set data to record - mean grey value only
//waitForUser("Checkpoint8", "Measurements set");
//measure bead signal:
		selectWindow(""+title2+"-green");						//select green channel
		roiManager("Show None");
		roiManager("Show All");									//apply ROI to channel
		roiManager("multi-measure measure_all one append");		//measure green channel
waitForUser("Checkpoint9", "Green Channel mesaured");	
		selectWindow(""+title2+"-green");
		close();												//close green channel
//waitForUser("Checkpoint10", "Green Channel closed");
//measure fusion (lysosome) signal:
		selectWindow("c:1/3 - "+title2+"");						//select red channel
		rename(""+title2+"-red");
		selectWindow(""+title2+"-red");
		roiManager("Show None");
		roiManager("Show All");									//apply ROI to channel
		roiManager("multi-measure measure_all one append");		//measure red channel
waitForUser("Checkpoint11", "Red Channel mesaured");
		roiManager("Delete");									//empty ROI manager
		selectWindow(""+title2+"-red");
		close();												//close red channel
//waitForUser("Checkpoint11", "Red Channel mesaured and closed");
}
//save Results:
	Dialog.create("Name Result file");							//get Results Filename from User
	Dialog.addString("Please name output file:", "");
	Dialog.show();
	v=Dialog.getString();
	
	selectWindow("Results");									//open Results Table
	saveAs("txt", dir2+v+".xls");
	N = nResults												//number of analysed particles
	showMessage("Report", ""+N+" Particles in "+list.length+" Images analysed - see output data in Destination Folder");	//Output Message
	run("Clear Results");										//empty Results Table
	updateResults;
	run("Close");												//close Results Table

