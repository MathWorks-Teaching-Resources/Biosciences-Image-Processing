function exports = SetupImageAppExports(lessonName)
%SetupImageAppExports - Reproduce interactive image-app exports for tests
%   EXPORTS = SetupImageAppExports(lessonName) creates deterministic masks
%   and properties from bundled images for the named courseware solution.
%   This setup is used only by test hooks, not by the learner lessons.
%
%   See also rgb2ycbcr, regionprops, bwareaopen, imfill

imageFolder = fullfile(currentProject().RootFolder, 'Images');
switch string(lessonName)
    case "S1PlantImageSegmentation"
        rgbImage = imread(fullfile(imageFolder, 'flowers.jpg'));
        channels = rgb2ycbcr(rgbImage);
        % Approximate the YCbCr ranges shown in the original screenshots.
        mask = channels(:,:,2) >= 130 & channels(:,:,2) <= 177 & ...
            channels(:,:,3) >= 151 & channels(:,:,3) <= 181;
        cleanedMask = imfill(bwareaopen(mask, 3000), 'holes');
        propertiesTable = regionprops('table', cleanedMask, ...
            'Area', 'EquivDiameter');
        propertiesTable = propertiesTable(propertiesTable.Area >= 8000 & ...
            propertiesTable.Area <= 22500, :);
    case "S2CellCounting"
        rgbImage = imread('coins.png');
        mask = imbinarize(rgbImage);
        propertiesTable = regionprops('table', mask, ...
            'Area', 'EquivDiameter');
    case "S3ProblemSet"
        rgbImage = imread(fullfile(imageFolder, 'Pv_troph_thinE.jpg'));
        channels = rgb2ycbcr(rgbImage);
        % Retain the pink cells while excluding background and purple stain.
        mask = channels(:,:,2) <= 138 & channels(:,:,3) >= 145;
        propertiesTable = table;
    otherwise
        error('SetupImageAppExports:UnknownLesson', ...
            'No app-export setup exists for %s.', lessonName)
end
maskedImage = rgbImage;
maskedImage(repmat(~mask, 1, 1, size(rgbImage,3))) = 0;
exports = struct('BW', mask, 'maskedRGBImage', maskedImage, ...
    'propsTable', propertiesTable);
end
