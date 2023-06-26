clc
clear

sir_values = 0:10;
merged_data = [];
merged_bits = [];
merged_bpsk = [];

for sir = sir_values
    % 파일 이름을 생성합니다.
    filename = sprintf('/home2/LIG/BPSK_LFM_Overlap_v2/sir_%d_dB.mat', sir);
    
    % mat 파일을 로드합니다.
    load(filename)
    
    % 데이터에서 원하는 부분을 추출합니다.
    extracted_data = overlap_stft(281:300,:,:);
    extracted_bits = bits(281:300,:);
    extracted_bpsk = bpsk_iq(281:300,:);
    
    % 병합된 데이터에 추출된 데이터를 추가합니다.
    if isempty(merged_data)
        merged_data = extracted_data;
        merged_bits = extracted_bits;
        merged_bpsk = extracted_bpsk;
    else
        merged_data = cat(1, merged_data, extracted_data);
        merged_bits = cat(1, merged_bits, extracted_bits);
        merged_bpsk = cat(1, merged_bpsk, extracted_bpsk);
   
    end
end
save('merged_data_and_bits.mat', 'merged_data', 'merged_bits','merged_bpsk');
%% step 2
clc
clear
load('pred_label.mat')
load('merged_data_and_bits.mat')

k = 220;
M = 128;
N = 256;
number = 1;
noise_std_dev = 0.001 + (0.01-0.001).*rand(1,1);
noise = noise_std_dev * randn(k ,M, N);

BW = pred_label;
se = strel('disk', 0);
dilated = imdilate(BW, se);
check = dilated(1,:,:);

inverted_pred_label = (255 - dilated)./255;
processed_data = merged_data.*inverted_pred_label ;
% processed_data = processed_data + noise.* pred_label;

tt = abs((squeeze(processed_data(number,:,:))));
imagesc(tt)
%% step3
fs = 1000;  
window_size = 128;
overlap = 124;
nfft = 128;
window = hann(window_size);
index =10 ;
sample = squeeze(processed_data(index,:,:));
bits= merged_bits(index,:);
restored_img = real(istft(sample, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));

num_samples = length(restored_img);
num_bits = num_samples / 4;

% 변환된 비트를 저장할 배열을 초기화합니다.
converted_bits = zeros(1, num_bits);

% 4개의 샘플마다 하나의 비트로 변환합니다.
for i = 1:num_bits
    sum_samples = sum(restored_img((i-1)*4+1:i*4));
    if sum_samples > 0
        converted_bits(i) = 1;
    else
        converted_bits(i) = 0;
    end
end

num_matched_elements = sum(bits == converted_bits);

% 정확도를 계산합니다.
accuracy = num_matched_elements / length(bits) * 100;

% 정확도를 출력합니다.
fprintf('Accuracy: %.2f%%\n', accuracy);


test = real(squeeze(merged_bpsk(index,:)));
figure(1)
imagesc(abs(sample))
figure(2)

plot(real(restored_img))
figure(3)
plot(test)
%% test
clc
clear
% 파일 이름을 생성합니다.
sir = 0;
fs = 1000;  
window_size = 128;
overlap = 124;
nfft = 128;
window = hann(window_size);
filename = sprintf('/home2/LIG/BPSK_LFM_Overlap_data/sir_%d_dB.mat', sir);

% mat 파일을 로드합니다.
load(filename)
image = squeeze(overlap_stft(1,:,:));
iq = overlap_iq(1,:);
iq_out = real(istft(image, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
% imagesc(image)
%% test 2
figure(1)
plot(iq_out)
figure(2)
plot(real(iq))

