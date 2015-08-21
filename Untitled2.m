close all

Dictionary=[Texture_Dict];
[x y]=size(Texture_Dict);
k=1;
j=1;
pic=[];
Texture_Dict=Texture_Dict-min(min(Texture_Dict));
Texture_Dict=Texture_Dict./max(max(Texture_Dict));
for i=1:size(Texture_Dict,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Texture_Dict(1:256,i),16,16);    
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Texture_Dict(1:256,i),16,16);
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Texture_Dict(1:256,i),16,16);
    j=j+1;
end
pic(:,30*17+18,:)=0;
pic(1:17:(k-1)*17+18,:,1)=255;
pic(:,1:17:30*17+18,1)=255;
figure;imshow(pic)
imwrite(pic,'Texture_DictHR.jpg')

Dictionary=[Texture_Dict];
[x y]=size(Texture_Dict);
k=1;
j=1;
pic=[];
Texture_Dict=Texture_Dict-min(min(Texture_Dict));
Texture_Dict=Texture_Dict./max(max(Texture_Dict));
for i=1:size(Texture_Dict,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Texture_Dict(257:512,i),16,16);    
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Texture_Dict(257:512,i),16,16);
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Texture_Dict(257:512,i),16,16);
    j=j+1;
end
pic(:,30*17+18,:)=0;
pic(1:17:(k-1)*17+18,:,1)=255;
pic(:,1:17:30*17+18,1)=255;
figure;imshow(pic)
imwrite(pic,'Texture_DictLR.jpg')

Dictionary=[Cartoon_Dict];
[x y]=size(Cartoon_Dict);
k=1;
j=1;
pic=[];
Cartoon_Dict=Cartoon_Dict-min(min(Cartoon_Dict));
Cartoon_Dict=Cartoon_Dict./max(max(Cartoon_Dict));
for i=1:size(Cartoon_Dict,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Cartoon_Dict(1:256,i),16,16);    
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Cartoon_Dict(1:256,i),16,16);
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Cartoon_Dict(1:256,i),16,16);
    j=j+1;
end
pic(:,30*17+18,:)=0;
pic(1:17:(k-1)*17+18,:,1)=255;
pic(:,1:17:30*17+18,1)=255;
figure;imshow(pic)
imwrite(pic,'Cartoon_DictHR.jpg')


Dictionary=[Cartoon_Dict];
[x y]=size(Cartoon_Dict);
k=1;
j=1;
pic=[];
Cartoon_Dict=Cartoon_Dict-min(min(Cartoon_Dict));
Cartoon_Dict=Cartoon_Dict./max(max(Cartoon_Dict));
for i=1:size(Cartoon_Dict,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Cartoon_Dict(257:512,i),16,16);    
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Cartoon_Dict(257:512,i),16,16);
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Cartoon_Dict(257:512,i),16,16);
    j=j+1;
end
pic(:,30*17+18,:)=0;
pic(1:17:(k-1)*17+18,:,1)=255;
pic(:,1:17:30*17+18,1)=255;
figure;imshow(pic)
imwrite(pic,'Cartoon_DictLR.jpg')

Dictionary=[Noblocking];
[x y]=size(Noblocking);
k=1;
j=1;
pic=[];
Noblocking=Noblocking-min(min(Noblocking));
Noblocking=Noblocking./max(max(Noblocking));
for i=1:size(Noblocking,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Noblocking(1:256,i),16,16);    
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Noblocking(1:256,i),16,16);
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Noblocking(1:256,i),16,16);
    j=j+1;    
end
pic(:,30*17+18,:)=0;
pic(1:17:(k-1)*17+18,:,1)=255;
pic(:,1:17:30*17+18,1)=255;
figure;imshow(pic)
imwrite(pic,'NoblockingHR.jpg')

Dictionary=[Noblocking];
[x y]=size(Noblocking);
k=1;
j=1;
pic=[];
Noblocking=Noblocking-min(min(Noblocking));
Noblocking=Noblocking./max(max(Noblocking));
for i=1:size(Noblocking,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Noblocking(257:512,i),16,16);    
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Noblocking(257:512,i),16,16);
    pic((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Noblocking(257:512,i),16,16);
    j=j+1;    
end
pic(:,30*17+18,:)=0;
pic(1:17:(k-1)*17+18,:,1)=255;
pic(:,1:17:30*17+18,1)=255;
figure;imshow(pic)
imwrite(pic,'NoblockingLR.jpg')


Dictionary=[Texture_Dict];
[x y]=size(Texture_Dict);
k=1;
j=1;
pic1=[];
pic2=[];
Texture_Dict=Texture_Dict-min(min(Texture_Dict));
Texture_Dict=Texture_Dict./max(max(Texture_Dict));
for i=1:size(Texture_Dict,2)    
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic1((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Texture_Dict(1:256,i),16,16);    
    pic1((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Texture_Dict(1:256,i),16,16);
    pic1((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Texture_Dict(1:256,i),16,16);
    j=j+1;    
end
Cartoon_Dict=Cartoon_Dict-min(min(Cartoon_Dict));
Cartoon_Dict=Cartoon_Dict./max(max(Cartoon_Dict));
for i=1:size(Cartoon_Dict,2) 
    if(mod(j,33)==0)
        k=k+1;
        j=1;
    end
    pic2((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,1)=reshape(Cartoon_Dict(1:256,i),16,16);    
    pic2((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,2)=reshape(Cartoon_Dict(1:256,i),16,16);
    pic2((k-1)*17+2:(k-1)*17+17,(j-1)*17+2:(j-1)*17+17,3)=reshape(Cartoon_Dict(1:256,i),16,16);
    j=j+1;    
end
pic1(:,30*17+18,:)=0;
pic1(1:17:(k-1)*17+18,:,1)=255;
pic1(:,1:17:30*17+18,1)=255;
pic2(:,30*17+18,:)=0;
pic2(1:17:(k-1)*17+18,:,1)=255;
pic2(:,1:17:30*17+18,1)=255;
figure;imshow(pic1)
figure;imshow(pic2)
imwrite(pic1,'Dict1.jpg')
imwrite(pic2,'Dict2.jpg')