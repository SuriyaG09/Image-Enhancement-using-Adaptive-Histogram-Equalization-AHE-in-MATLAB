%% final code
clc
clear 
close all
addpath('Method');
Image_dir = 'Image';
listing = cat(1, dir(fullfile(Image_dir, '*.jpg')));

% The final output will be saved in this directory:
result_dir = fullfile(Image_dir, 'result_blood_smear');

% Preparations for saving results.
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

for i_img = 1:length(listing)
    Input = imread(fullfile(Image_dir,listing(i_img).name));
    [~, img_name, ~] = fileparts(listing(i_img).name);
    img_name = strrep(img_name, '_input', ''); 

    %% breaks the img into rgb and do histogram equali in each of rgb
    Input_red = Input(:,:,1);
    Input_green = Input(:,:,2);
    Input_blue = Input(:,:,3);

    %% Adaptive Histogram Equalization (AHE) - contrast enhancement that applies histogram equalization 
    %% to small regions of an image instead of the entire image.

    % Apply the histogram equalization and median filtering (for noise reduction) to each channel separately
    
    % Red
    Input_red_eq = adapthisteq(Input_red,'NumTiles',[8 8],'ClipLimit',0.02);
    Input_red_median = medfilt2(Input_red_eq,[3 3]);
    % Green
    Input_green_eq = adapthisteq(Input_green,'NumTiles',[8 8],'ClipLimit',0.02);
    Input_green_median = medfilt2(Input_green_eq,[3 3]);
    % Blue
    Input_blue_eq = adapthisteq(Input_blue,'NumTiles',[8 8],'ClipLimit',0.02);
    Input_blue_median = medfilt2(Input_blue_eq,[3 3]);

    %% Merge the three channels back into a color image
    Input_eq_med = cat(3, Input_red_median, Input_green_median, Input_blue_median);
    
    %% Unsharp masking for sharpening details
    Input_Unsharp = imsharpen(Input_eq_med,'Radius',1.5,'Amount',1);
    
    %% Storing the output 
    imwrite(Input_Unsharp, fullfile(result_dir, [img_name, '_enhanced.jpg'])); 
end
