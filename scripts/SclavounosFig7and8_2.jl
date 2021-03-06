
using LiftingLineTheory
using PyPlot

let
    println("Note that due to a difference between this implementation"*
        " and Sclavounos' implementation, the high frequency response "*
        " differs. See Bird & Ramesh, 2019, TCFD.")
    span = 1
    aspect_ratio = 4 
    wing = LiftingLineTheory.make_rectangular(StraightAnalyticWing, 
        aspect_ratio, span)
    srfs = collect(0.01:0.2:8)
    omegas = 2 * srfs / span;
    amcl_abs = zeros(length(srfs))
    amcl_ph = zeros(length(srfs))
    cl_abs = zeros(length(srfs))
    cl_ph = zeros(length(srfs))
    stcl_abs = zeros(length(srfs))
    stcl_ph = zeros(length(srfs))

    chord = span / aspect_ratio;
    added_mass = 0.75 * span * chord^2 * pi / 2.;

    for i = 1 : length(srfs)
        prob = HarmonicULLT2(omegas[i], wing; num_terms = 9)
        compute_collocation_points!(prob)
        compute_fourier_terms!(prob)
        cl = lift_coefficient(prob, added_mass)
        amcl_abs[i] = abs(cl)
        amcl_ph[i] = atan(imag(cl), real(cl))

        prob = HarmonicULLT(omegas[i], wing; num_terms = 9)
        compute_collocation_points!(prob)
        compute_fourier_terms!(prob)
        cl = lift_coefficient(prob)
        cl_abs[i] = abs(cl)
        cl_ph[i] = atan(imag(cl), real(cl))

        prob = HarmonicULLT2(omegas[i], wing; downwash_model=strip_theory)
        compute_collocation_points!(prob)
        compute_fourier_terms!(prob)
        stcl = lift_coefficient(prob, added_mass)
        stcl_abs[i] = abs(stcl)
        stcl_ph[i] = atan(imag(stcl), real(stcl))
    end

    figure()
    ax = gca()
    ax.imshow(imread("scripts/Sclav87ref/Fig7.PNG"), extent=[0, 8, 0, 8])
    ax.set_aspect("auto")
    plot(srfs, amcl_abs, label="Sclav ULLT")
    plot(srfs, cl_abs, label="HJAB ULLT")
    plot(srfs, stcl_abs, label="Strip theory")
    xlabel("Span reduced frequency")
    ylabel("ABS(C_L)")

    figure()
    ax = gca()
    ax.imshow(imread("scripts/Sclav87ref/Fig8.PNG"), extent=[0, 8, -270, 0])
    ax.set_aspect("auto")
    plot(srfs, ((rad2deg.(amcl_ph) .+ 360) .% 360) .-360, label="Sclav ULLT")
    plot(srfs, ((rad2deg.(cl_ph) .+ 360) .% 360) .-360, label="HJAB ULLT")
    plot(srfs, ((rad2deg.(stcl_ph) .+ 360) .% 360) .-360, label="Strip theory")
    xlabel("Span reduced frequency")
    ylabel("Ph(C_L)")
    return srfs, cl_abs, cl_ph
end