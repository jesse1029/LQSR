function x=remove_ba(f)

%Remove the blocking artifacts horizontally and vertically


ff=f;

[height,width]=size(f);

f1 = double(f) -128; % Level shift input


fun1 = @dct2;

g = blkproc(f1,[8 8], fun1); % F= T*f*T'


%%Horizontally

f2=f1(:,5:width-4);%Block C matrix

g2 = blkproc(f2,[8 8], fun1);% DCT of C


i8=width/8;i82=i8-1;

t12=350;t22=120;t32=60;%Thresholds

alfa0=0.6;beta0=0.2;

alfa1=0.5;beta1=0.25;


for j=1:i8

for i=1:i82

a1=g((j-1)*8+1:j*8,(i-1)*8+1:i*8); %Block A

b1=g((j-1)*8+1:j*8,i*8+1:(i+1)*8); %Block B

c1=g2((j-1)*8+1:j*8,(i-1)*8+1:i*8); %Block C

t1=abs(a1(1,1)-b1(1,1)); %T1

t2=abs(a1(1,2)-b1(1,2)); %T2

t3=abs(c1(4,4)); %T3

if t1

ind(j,i)=1; %Modification indicator


v1=1:1:2;

c1(1,v1)=alfa0*c1(1,v1)+beta0*(a1(1,v1)+b1(1,v1));

v2=4:2:8;

c1(1,v2)=alfa1*c1(1,v2)+beta1*(a1(1,v2)+b1(1,v2));

g2((j-1)*8+1:j*8,(i-1)*8+1:i*8)=c1; % Modification


else ind(j,i)=0;

end

end

end


fun2 = @idct2;

fr2 = blkproc(g2,[8 8], fun2);

fr2 = uint8(fr2 + 128);


for j=1:i8

for i=1:i82

if ind(j:i)==1

ff((j-1)*8+1:j*8,(i-1)*8+1+4:i*8+4)=fr2((j-1)*8+1:j*8,(i-1)*8+1:i*8);

end

end

end



%%Vertically

fv2=f1(5:height-4,:);%Block C matrix

gv2 = blkproc(fv2,[8 8], fun1);% DCT of C


i8=height/8;

i82=i8-1;


for j=1:i8

for i=1:i82

av1=g((i-1)*8+1:i*8,(j-1)*8+1:j*8); %Block A

bv1=g(i*8+1:(i+1)*8,(j-1)*8+1:j*8); %Block B

cv1=gv2((i-1)*8+1:i*8,(j-1)*8+1:j*8); %Block C

tv1=abs(av1(1,1)-bv1(1,1)); %T1

tv2=abs(av1(1,2)-bv1(1,2)); %T2

tv3=abs(cv1(4,4)); %T3


if tv1

indv(i,j)=1; %Modification indicator


v1=1:1:2;

cv1(v1,1)=alfa0*cv1(v1,1)+beta0*(av1(v1,1)+bv1(v1,1));

v2=4:2:8;

cv1(v2,1)=alfa1*cv1(v2,1)+beta1*(av1(v2,1)+bv1(v2,1));

gv2((i-1)*8+1:i*8,(j-1)*8+1:j*8)=cv1;

else indv(i,j)=0;

end

end

end


fun2 = @idct2;

frv2 = blkproc(gv2',[8 8], fun2)';

frv2 = uint8(frv2 + 128);


for j=1:i8

for i=1:i82

if indv(i,j)==1

ff((i-1)*8+1+4:i*8+4,(j-1)*8+1:j*8)=frv2((i-1)*8+1:i*8,(j-1)*8+1:j*8);

end

end

end


x=ff;