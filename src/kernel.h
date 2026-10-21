// kernel.h - Core data architectures for Bare Metal AlphaOS
#pragma once
#include <stdint.h>

constexpr int64_t SCALE = 10000; // 1.0 = 10000 fixed point ( base-100 mechanism)

// Layer 6: Norm Grammar - Pair representation holding whole state
struct Fixed {
    int64_t v;
    
    // Shakuntala x5 trick: v * 5 = (v * 10) / 2
    constexpr Fixed mul5() const { return {(v * 10) / 2}; }
    constexpr Fixed mul25() const { return {(v * 100) / 4}; }
    
    // Base 100 multiplication method: (100 - x)(100 - y) = 100(100 - x - y) + xy
    static constexpr int64_t fast_mul(int64_t a, int64_t b) {
        int64_t da = a - SCALE;
        int64_t db = b - SCALE;
        return SCALE * (a + db) / SCALE + (da * db) / SCALE;
    }
};

struct alignas(64) Option {
    int64_t strike; // Scaled by SCALE
    int64_t bid;    // Scaled by SCALE
    int64_t ask;    // Scaled by SCALE
    int64_t spot;   // Scaled by SCALE
    uint32_t dte;   // Days to expiry
    uint32_t seq;   // Sequence or Symbol tracking hash
};

template<int N>
struct alignas(64) OptionRing {
    Option buf[N];
    volatile uint32_t head = 0;
    volatile uint32_t tail = 0;
    
    bool push(const Option& o) {
        uint32_t nh = (head + 1) % N;
        if (nh == tail) return false; // Buffer overflow protective block
        buf[head] = o;
        head = nh;
        return true;
    }
};

struct alignas(64) ChainView {
    Option* display; // Reader buffer
    Option* render;  // Writer buffer
    Option* spare;   // Intermediate swap buffer
    
    Option poolA[256];
    Option poolB[256];
    Option poolC[256];
    
    ChainView() {
        display = poolA;
        render = poolB;
        spare = poolC;
    }
    
    // Triple swap mechanism: Atomic pointer shuffling preventing memory fission
    void swap_ptr() {
        Option* t = display;
        display = render;
        render = spare;
        spare = t;
    }
};
