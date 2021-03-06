#=
A comparison of LAULLT and Sclavounos' theory for small amplitude
heave of an AR3 wing.
=#

using LiftingLineTheory
using PyPlot
using DelimitedFiles

let
    AR = 6
    wing = LiftingLineTheory.make_rectangular(StraightAnalyticWing, AR, AR)
    #srf = 0.4
    k = 0.4#srf / AR
    srf = k * AR
    #degrees = 35
    amp = 0.05#deg2rad(degrees)
    omega = 2 * k
    dt = 0.05
    ossl = 4
    nsteps = Int64(ceil(2 * pi * wing.chord_fn(0.0) / (2 * 1 * k * dt) * 4))
    ninner = 55
    #casename = "AR"*string(AR)*"Rect_LEpOsc"*string(degrees)*"_k"*string(k)*"_Ni"*string(ninner)*"_dt"*string(dt)
    casename = "AR"*string(AR)*"Rect_hOsc"*string(amp)*"_k"*string(k)*"_Ni"*string(ninner)*"_dt"*string(dt)
    casename = replace(casename, "." => "p")

	println("Case "*casename)
	println("k = ", k)
	println("srf = ", srf)
	println("AR = ", AR)
    println("dt = ", dt)
    println("dtstar = ", 1 / wing.chord_fn(0) * dt)
	println("amp = ", amp)

    #probs = HarmonicULLT(omega, wing)
    #compute_collocation_points!(probs)
    #compute_fourier_terms!(probs)
    #cls = lift_coefficient(probs) * im * omega * amp
    #figure()
    #ts = collect(0:dt:dt*nsteps)
    #clst = real.(cls .* exp.(im * omega * ts))
    #plot(ts, clst, label="Sclavounos")
    bigsegs= range(-1, 1, length=ninner+1)
    innersolpos = collect((bigsegs[2:end]+bigsegs[1:end-1])./2)
    segs = collect(range(-1, 1, length=1*ninner+1))


    #prob = LAULLT(;kinematics=RigidKinematics2D(x->amp*cos(omega*x), x->0, 0.5),
    #    wing_planform=wing, dt=dt)
    #prob = LAULLT(;kinematics=RigidKinematics2D(x->0, x->amp*cos(omega*x), -0.5),                    # LE PITCH
    #    wing_planform=wing, dt=dt, segmentation=segs, inner_solution_positions=innersolpos)
    prob = LAULLT(;kinematics=RigidKinematics2D(x->amp * cos(omega * x), x->0, 0.0),       # HEAVE
        wing_planform=wing, dt=dt, segmentation=segs, inner_solution_positions=innersolpos)
    println("n_inner = ", length(prob.inner_sols))
    println("inner_sol_pos = ", prob.inner_sol_positions)
    println("Segmentation = ", prob.segmentation)
    
    hdr = csv_titles(prob)
    rows = zeros(0, length(hdr))
    print("\nLAULLT\n")
    for i = 1 : nsteps
        print("\rStep ", i, " of ", nsteps, ".\t\t\t\t\t")
        advance_one_step(prob)
        rows = vcat(rows, csv_row(prob))
    end
    to_vtk(prob, casename)
    #plot(rows[50:end, 1], rows[50:end, 5], label="LAULLT")

    #prob2d = LAUTAT(;kinematics=RigidKinematics2D(x->amp * cos(omega * x), x->0, 0.0), dt=dt)
    #hdr2d = csv_titles(prob2d)
    #rows2d = zeros(0, length(hdr2d))
    #print("\nLAUTAT\n")
    #for i = 1 : nsteps
    #    print("\rStep ", i, " of ", nsteps, ".\t\t\t\t\t")
    #    advance_one_step(prob2d)
    #    rows2d = vcat(rows2d, csv_row(prob2d))
    #end
    #println("\n")
    #plot(rows2d[50:end, 1], rows2d[50:end, 9], label="LAUTAT")

    
    #probs = HarmonicULLT(omega, wing; downwash_model=streamwise_filaments)
    #compute_collocation_points!(probs)
    #compute_fourier_terms!(probs)
    #cls = lift_coefficient(probs) * im * omega * amp
    #ts = collect(0:dt:dt*nsteps)
    #clst = real.(cls .* exp.(im * omega * ts))
    #plot(ts, clst, label="Streamwise filaments ULLT")
    
    #cls = LiftingLineTheory.theodorsen_simple_cl(k, amp, 0)
    #ts = collect(0:dt:dt*nsteps)
    #clst = real.(cls .* exp.(im * omega * ts))
    #plot(ts, clst, label="Theodorsen")

    #clst2d = LiftingLineTheory.theodorsen_simple(k, amp, 0)
    #ts = collect(0:dt:dt*nsteps)
    #clst2d = real.(clst2d .* exp.(im * omega * ts))
    #plot(ts, clst2d, label="Theodorsen")

    #xlabel("Time")
    #ylabel("C_L")
    #legend()

    #figure()
    #plot(rows[50:end, 1], rows[50:end, 7], label="LAULLT A0 edge")
    #plot(rows[50:end, 1], rows[50:end, 7+4*7], label="LAULLT A0 8")
    #plot(rows2d[50:end, 1], rows2d[50:end, 7], label="LAUTAT A0")
    #plot(rows[50:end, 1], rows[50:end, 8], label="LAULLT A1 edge")
    #plot(rows[50:end, 1], rows[50:end, 8+4*7], label="LAULLT A1 8")
    #plot(rows2d[50:end, 1], rows2d[50:end, 8], label="LAUTAT A1")
    #legend()

    writefile = open(casename*".csv", "w")
    writedlm(writefile, hdr, ", ")
    writedlm(writefile, rows, ", ")
    close(writefile)

    #return prob, rows, hdr
end
