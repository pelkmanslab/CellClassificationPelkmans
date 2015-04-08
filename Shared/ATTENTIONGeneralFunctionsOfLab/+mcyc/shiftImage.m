function ShiftedImage = shiftImage(ImageToShift,x_correction,y_correction)
% Shifts images as in the ShiftImage module: creates equally sized image,
% where regions outside of shift are zero
% Note: shifting vector has to be inverted compared to Markus' aligncycles
% settings files (if a segmentation has to be mapped back);
% example: x_correction = 10;  and y_correction=-20; means that bottom
% left corner of image will have zeros

%%% get the output image
ShiftedImage = zeros(size(ImageToShift),'double');

% Trivial case: shift number is larger than image
if (abs(x_correction)>=size(ImageToShift,1)) || (abs(y_correction)>=size(ImageToShift,2));
    rowsAtBorder = NaN;
    columnsAtBorder = NaN;
    return;
end

% define the change
if y_correction > 0
    final_index_one = abs(y_correction)+1:size(ImageToShift,1);
    orig_index_one = 1:size(ImageToShift,1)-abs(y_correction);
elseif y_correction < 0
    final_index_one = 1:size(ImageToShift,1)-abs(y_correction);
    orig_index_one = abs(y_correction-1):size(ImageToShift,1);%GG changed +1 to -1
else
    final_index_one = 1:size(ImageToShift,1);
    orig_index_one = 1:size(ImageToShift,1);
end
    

if x_correction > 0
    final_index_two = abs(x_correction+1):size(ImageToShift,2);
    orig_index_two = 1:size(ImageToShift,2)-abs(x_correction);
elseif x_correction < 0
    final_index_two = 1:size(ImageToShift,2)-abs(x_correction);
    orig_index_two = abs(x_correction-1):size(ImageToShift,2);%GG changed +1 to -1
else
    final_index_two = 1:size(ImageToShift,2);
    orig_index_two = 1:size(ImageToShift,2);
end
    

% change the 
ShiftedImage(final_index_one,final_index_two)=ImageToShift(orig_index_one,orig_index_two);


% % Create additional outputs (for tracking cells, which should be discarded)
% rowsAtBorder = [final_index_one(1) final_index_one(end)];
% columnsAtBorder = [final_index_two(1) final_index_two(end)];



end