
	dir1 = getDirectory("Choose source directory "); 			//request source dir via window
	list = getFileList(dir1);									// read file list
	dir2 = getDirectory("Choose destination directory ");		//request source dir via window
	N=0; 														//set particle counter=0
	run("Clear Results");										//to start with an empty results table
	updateResults; 

//start loop:
	for (i=0; i<list.length; i++) {								//set i=0, count nuber of list items, enlagre number +1 each cycle, start cycle at brackets

		path = dir1+list[i];									//path location translated for code

		run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default"); 	//skips open dialog from bioformats and opens path

		title1= getTitle;
		title2 = File.nameWithoutExtension;						//filename as ID (SO NO DOUBLE FINLENAMES!)
			//waitForUser("Checkpoint1", "opened");

		run("Stack to Images");									//separate channels
			//waitForUser("Checkpoint2", "channels separated");

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

		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=4");					//higher contrast supports particle detection
		run("Apply LUT");
		run("Close");
//waitForUser("Checkpoint", "Enh.Contrast1");
run("Convoluted Background Subtraction", "convolution=Gaussian radius=7");
//waitForUser("Checkpoint", "Gauss");
run("Despeckle");
run("Despeckle");
	run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=7");					//higher contrast supports particle detection
		run("Apply LUT");
		run("Close");
//waitForUser("Checkpoint", "Enh.Contrast2");
		setAutoThreshold("Intermodes dark");					//dark Background - important (Intermodes or Huang is good as well with adaptions)
		setOption("BlackBackground", true);						//MUST BE "TRUE" FOR BIOVOXXEL TOOLS!
		run("Convert to Mask");									//generate mask for ROI
//waitForUser("Checkpoint5", "binary");

	run("EDM Binary Operations", "iterations=3 operation=close");
//waitForUser("Checkpoint5", "close");
	//run("Fill Holes"); 										//optional - prown to hinder wahtershed from working well	
//waitForUser("Checkpoint5", "fill");	
	run("Watershed");
//waitForUser("Checkpoint", "Whatershed1");
	run("Watershed Irregular Features", "erosion=10 convexity_threshold=0 separator_size=0-200");
//waitForUser("Checkpoint5", "watershed2");
	
//waitForUser("Checkpoint5", "Mask ready");
		//ALT://run("Analyze Particles...", "size=1-5 circularity=0.90-1.00 show=[Bare Outlines] exclude add"); //find beads
run("Analyze Particles...", "size=0.50-2.0 circularity=0.81-1.00 show=[Bare Outlines] exclude summarize include add"); //size may be further adjusted
//waitForUser("Checkpoint6", "Particles analyzed");
		selectWindow(""+title2+"-green-1");						//close duplicated image
		close();
//saving ROI outlines for troubleshooting:
		selectWindow("Drawing of "+title2+"-green-1");			//select Drawing of ROI s
		saveAs("Gif", dir2+title2+"-green.gif");				//save Drawing of ROI s
		close();												//close Drawing of ROI s
//waitForUser("Checkpoint12", "Drawing saved");
		N=N+roiManager("count"); 								// summ all analysed particles ( "particle counter")
		run("Set Measurements...", "mean display redirect=None decimal=2");	//set data to record - mean grey value only
//waitForUser("Checkpoint8", "Measurements set");
//measure bead signal:
		selectWindow(""+title2+"-green");						//select green channel
		roiManager("Show None");
		roiManager("Show All");									//apply ROI to channel
		roiManager("multi-measure measure_all one append");		//measure green channel
//waitForUser("Checkpoint9", "Green Channel mesaured");	
		selectWindow(""+title2+"-green");
		close();												//close green channel
//waitForUser("Checkpoint10", "Green Channel closed");
//measure fusion (lysosome) signal:
		selectWindow("c:1/3 - "+title2+"");						//select red channel
		rename(""+title2+"-red");
		selectWindow(""+title2+"-red");
		roiManager("Show None");
		roiManager("Show All");									//apply ROI to channel
waitForUser("Checkpoint11", "Mask applied on red channel");
		roiManager("multi-measure measure_all one append");		//measure red channel
		roiManager("Delete");									//empty ROI manager
		selectWindow(""+title2+"-red");
		close();												//close red channel
//waitForUser("Checkpoint12", "Red Channel mesaured and closed");
}
//save Results:
	Dialog.create("Name Result file");							//get Results Filename from User
	Dialog.addString("Please name output file:", "");
	Dialog.show();
	v=Dialog.getString();
	
	selectWindow("Results");									//open Results Table
	saveAs("txt", dir2+v+".xls");

	run("Clear Results");										//empty Results Table
	updateResults;
	run("Close");												//close Results Table

	showMessage("Report", ""+N+" Particles in "+list.length+" Images analysed - see output data in Destination Folder");	//Output Message
	N=0 														//reset particle counter