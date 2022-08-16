# TODO: are there more we should get?
#       Can we get cycles per instruction for these?
Base.@kwdef struct InstructionList{T}
    pushq::T
    subq::T
    movq::T
    vmovsd::T
    movabsq::T
    leaq::T
    callq::T
    vmovups::T
    addq::T
    popq::T
    vzeroupper::T
    retq::T
    nopw::T
    shrq::T
    andl::T
    cmpl::T
    vroundsd::T
    shrl::T
    movl::T
    cmpq::T
    vandpd::T
    vucomisd::T
    vsubsd::T
    vxorpd::T
    vmovq::T
    vmulsd::T
    vfmadd213sd::T
    vaddsd::T
    vfmadd231sd::T
    subl::T
    vfmsub231sd::T
    vmovapd::T
    vcvttsd2si::T
    testq::T
end
