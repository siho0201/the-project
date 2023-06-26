function bpsk_signal = bpsk(bits, t, phase, symbol_duration, bandwidth) % Input Bits, Times, Phase, Symbol Duration, Bandwidth
    dt = t(2) - t(1);
    fs = 1/dt;
    for i = 1 : length(t)
        bpsk(i) = exp(1i*phase(i))*(2*bits(ceil(i/(symbol_duration/dt))) - 1);   % bpsk 신호 생성
    end
    cutoff_freq = bandwidth/2.0; % 대역폭 제한할 컷오프 주파수
    normalized_cutoff_freq = cutoff_freq / (fs/2);
    order = 30; % 필터의 계수
    b = fir1(order, normalized_cutoff_freq);
    bpsk_signal = filter(b, 1, bpsk); % FIR 필터링된 신호
    
    delay = floor(order/2); % FIR 필터의 딜레이 값
    
    % FIR 필터링된 신호를 원래 위치로 이동
    bpsk_signal = circshift(bpsk_signal, -delay);
end