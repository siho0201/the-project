clc
clear

sir_values = 0:10;
merged_data = [];
merged_bits = [];
merged_bpsk = [];
merged_bpsk_stft = [];
total_data = [];

for sir = sir_values
    % 파일 이름을 생성합니다.
    filename = sprintf('/home2/LIG/BPSK_LFM_Overlap_data/sir_%d_dB.mat', sir);
    
    % mat 파일을 로드합니다.
    load(filename)
    
    % 데이터에서 원하는 부분을 추출합니다.
    extracted_data = overlap_stft(281:300,:,:);
    extracted_bits = bits(281:300,:);
    extracted_bpsk = bpsk_iq(281:300,:);
    extracted_bpsk_stft = bpsk_stft(281:300,:,:);
    
    % 병합된 데이터에 추출된 데이터를 추가합니다.
    if isempty(merged_data)
        merged_data = extracted_data;
        merged_bits = extracted_bits;
        merged_bpsk = extracted_bpsk;
        merged_bpsk_stft = extracted_bpsk_stft;
        total_data = overlap_stft;
    else
        merged_data = cat(1, merged_data, extracted_data);
        merged_bits = cat(1, merged_bits, extracted_bits);
        merged_bpsk = cat(1, merged_bpsk, extracted_bpsk);
        merged_bpsk_stft = cat(1, merged_bpsk_stft, extracted_bpsk_stft); 
        total_data = cat(1, total_data, overlap_stft);
    end
end
save('merged_data_and_bits2.mat', 'merged_data', 'merged_bits','merged_bpsk','merged_bpsk_stft','total_data');
%% step2
clc
clear
load('pred_label2.mat')
load('merged_data_and_bits2.mat')

fs = 1000;  
window_size = 128;
overlap = 124;
nfft = 128;
window = hann(window_size);

abs_re = abs(merged_data) - pred_label ;
phase = angle(merged_data);
sir_accuracies = zeros(1, 11);
sir_bits = 20;
num_sirs = 11;
bit_errors = zeros(1,num_sirs);

for number = 1:220
    abs_sample = squeeze(abs_re(number,:,:));
    phase_sample = squeeze(phase(number,:,:));
    
    abs_sample(abs_sample <1) =0;
    phase_sample(abs_sample ==0) = 0;
    
    complex_exponential = exp(1i * phase_sample);
    sample_stft = abs_sample.*complex_exponential;
    
    sample_iq = real(istft(sample_stft, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
    sample_iq(1:8)= 0;
    sample_iq(end-7:end) = 0;
    
    answer_stft = squeeze(merged_bpsk_stft(number,:,:));
    answer_iq = real(istft(answer_stft, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
    
    num_samples = length(answer_iq);
    num_bits = num_samples / 4;
    % 변환된 비트를 저장할 배열을 초기화합니다.

    converted_bits = zeros(1, num_bits);
    bits = zeros(1, num_bits);
    
    % 4개의 샘플마다 하나의 비트로 변환합니다.
    for i = 1:num_bits
        sum_samples = sum(sample_iq((i-1)*4+1:i*4));
        if sum_samples > 0
            converted_bits(i) = 1;
        else
            converted_bits(i) = 0;
        end
    end
   
    % 4개의 샘플마다 하나의 비트로 변환합니다.
    for i = 1:num_bits
        sum_samples = sum(answer_iq((i-1)*4+1:i*4));
        if sum_samples > 0
            bits(i) = 1;
        else
            bits(i) = 0;
        end
    end
    num_matched_elements = sum(bits == converted_bits);
    accuracy = num_matched_elements / length(bits) * 100;
    % fprintf('Accuracy: %.2f%%\n', accuracy);
    sir_index = ceil(number/20);
    
    % 해당 SIR에 대한 정확도를 배열에 추가
    sir_accuracies(sir_index) = sir_accuracies(sir_index) + accuracy;
    bit_error = sum(bits~=converted_bits);
    sir_index = ceil(number / sir_bits);
    bit_errors(sir_index) = bit_errors(sir_index) + bit_error;

end


% 각 SIR에 대한 정확도의 평균을 계산
sir_accuracies = sir_accuracies / 20;
% 각 SIR에 대한 bit error rate를 계산합니다.
bit_error_rate = bit_errors / (num_samples / 4) / sir_bits;

% 전체 평균 정확도를 계산
mean_accuracy = mean(sir_accuracies);

fprintf('Mean Accuracy: %.2f%%\n', mean_accuracy);

%% 

% SIR 값 벡터를 생성
sir_values = -10:0;
sir_accuracies = bit_error_rate(end:-1:1);

% 평균 정확도를 플로팅
figure;
plot(sir_values, sir_accuracies, '-o');
xlabel('SIR');
ylabel('BER');
% title('Mean Accuracy per SIR');
% ylim([0 100]);  % Y 축의 범위를 0에서 100으로 설정
grid on;

% 그래프 저장
% saveas(gcf, 'accuracy_vs_sir.png');
%%
abs_sample = squeeze(abs_re(1,:,:));
phase_sample = squeeze(phase(1,:,:));

abs_sample(abs_sample<1) =0;
phase_sample(abs_sample==0) = 0;

complex_exponential = exp(1i * phase_sample);
sample_stft = abs_sample.*complex_exponential;

sample_iq = real(istft(sample_stft, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
sample_iq(1:8)= 0;
sample_iq(end-7:end) = 0;

answer_stft = squeeze(merged_bpsk_stft(1,:,:));
answer_iq = real(istft(answer_stft, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
%%

plot(answer_iq);
xlabel('Time');
ylabel('Amplitude');
xlim([0 1148]);
% title('Mean Accuracy per SIR');
saveas(gcf, 'ori_bpsk_iq.png');
%%
sample = abs(squeeze(lfm_stft(2,:,:)));
imagesc(sample)
saveas(gcf, 'ori_lfm.png');