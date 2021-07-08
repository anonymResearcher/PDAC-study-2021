% color deconvolution project by Jakob Nikolas Kather, 2015
% contact: www.kather.me

function imageOut = SeparateStains(imageRGB, Matrix)

    % convert input image to double precision float
    % add 2 to avoid artifacts of log transformation
    imageRGB = double(imageRGB)+2;

    % perform color deconvolution
    imageOut = reshape(-log(imageRGB),[],3) * Matrix;
    imageOut = reshape(imageOut, size(imageRGB));

    % post-processing
    %{ 
    extremePoints = zeros(8,3);
    for iii=0:7
        extremePoints(iii+1,:) = -log(cellfun(@str2double,mat2cell(dec2bin(iii,3),1,ones(1,3))).*[100 100 155]+2);
    end
    extremePoints = -log(...
       [0    0   0;...
         255 255 255;...
         100  25  30;...
         100 100  30;...
         175 150 250;...
         125 200 250;...
          15   0 140;...
          15  75 140;...
         ]+2);
      
    deconvPoints = extremePoints*Matrix;
    minV = min(deconvPoints);
    maxV = max(deconvPoints);
    
    minV = repmat(reshape(minV,1,1,3),size(imageOut,1),size(imageOut,2));
    maxV = repmat(reshape(maxV,1,1,3),size(imageOut,1),size(imageOut,2));
    imageOut = (imageOut -minV)./(maxV-minV);
    %}
end
