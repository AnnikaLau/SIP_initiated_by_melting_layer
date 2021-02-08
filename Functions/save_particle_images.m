% per is percentage of images that will randomly be saved
% Randomly saves x% of all ice crystals as a scaled image and as an image
% with the orignal size
function save_particle_images(ice_crystals,saving_folder,per)
load(ice_crystals)
map = gray;

for i = 1:length(temp1.prtclIm)
    h = abs(temp1.prtclIm{i});
    h = mat2gray(h);
    imagesc(h);
    colormap(map);
    axis image;
    axis tight off;
    frame = getframe(gca);
    framedata = frame.cdata;
    he = size(h,1);
    w = size(h,2);
    t = split(temp1.prtclID{i},'_');
    t = t{1};
    t = t(12:19);
    
    %Get random selection
    s = rand;
       
    %% Save random particles not scaled
    if s <= per/100
        imwrite(h, fullfile(saving_folder,strcat(t,'_',temp1.cpType{i},'_',num2str(i),'_scaled','.png')))
        imwrite(framedata,fullfile(saving_folder,strcat(t,'_',temp1.cpType{i},'_',num2str(he),'_height','.png')))
    end
end
end