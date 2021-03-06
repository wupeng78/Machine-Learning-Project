function genSP(testImgName,kNNImgNums)

global ALLIMAGES ALLSUPIX TESTIMAGES  TESTSUPIX  TRAINIMAGES  TRAINSUPIX 

dirList = dir(ALLIMAGES);
dirList = dirList(3:end); %remove . and .. from list

if ~exist('cncut')
    addpath('/usr0/home/nitisht/Documents/MLProject/labelprop/superpixels64/yu_imncut');
end

%imgList = {fullfile(HOMEIMAGES,testImgName)};
imgList = {testImgName};
i = 1;
for imgNum = kNNImgNums
	imgList(end + 1) = {dirList(imgNum).name};
	%imgList(end + 1) = {fullfile(HOMEIMAGES,dirList(imgNum).name)};
	i = i +1;
end

imgList
for imgName = imgList
	imgName = imgName{1}
	spname = fullfile(HOMESP,imgName)
	if exist(strcat(spname(1:end-3),'S1.csv')) && exist(strcat(spname(1:end-3),'S2.csv')) && exist(strcat(spname(1:end-3),'S3.csv'))
		continue;
	end
	
	I = im2double(imread(fullfile(HOMEIMAGES,imgName)));
	
	N = size(I,1);
	M = size(I,2);

	% Number of superpixels coarse/fine.
	N_sp=200;
	N_sp2=1000;
	% Number of eigenvectors.
	N_ev=40;


	% ncut parameters for superpixel computation
	diag_length = sqrt(N*N + M*M);
	par = imncut_sp;
	par.int=0;
	par.pb_ic=1;
	par.sig_pb_ic=0.05;
	par.sig_p=ceil(diag_length/50);
	par.verbose=0;
	par.nb_r=ceil(diag_length/60);
	par.rep = -0.005;  % stability?  or proximity?
	par.sample_rate=0.2;
	par.nv = N_ev;
	par.sp = N_sp;

	% Intervening contour using mfm-pb
	fprintf('running PB\n');
	[emag,ephase] = pbWrapper(I,par.pb_timing);
	emag = pbThicken(emag);
	par.pb_emag = emag;
	par.pb_ephase = ephase;
	clear emag ephase;

	st=clock;
	fprintf('Ncutting...');
	[Sp,Seg] = imncut_sp(I,par);
	fprintf(' took %.2f minutes\n',etime(clock,st)/60);

	st=clock;
	fprintf('Fine scale superpixel computation...');
	Sp2 = clusterLocations(Sp,ceil(N*M/N_sp2));
	fprintf(' took %.2f minutes\n',etime(clock,st)/60);
	
	%{
	I_sp = segImage(I,Sp);
	I_sp2 = segImage(I,Sp2);
	I_seg = segImage(I,Seg);
	figure();
	subplot(1,4,1);
	imshow(I);
	subplot(1,4,2);
	imshow(I_seg);
	subplot(1,4,3);
	imshow(I_sp);
	subplot(1,4,4);
	imshow(I_sp2);
	%}

	dlmwrite(strcat(spname(1:end-3),'S1.csv'),Seg)
	dlmwrite(strcat(spname(1:end-3),'S2.csv'),Sp)
	dlmwrite(strcat(spname(1:end-3),'S3.csv'),Sp2)
end

