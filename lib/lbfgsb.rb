# frozen_string_literal: true

require 'numo/narray'
require 'lbfgsb/version'
require 'lbfgsb/lbfgsbext'

module Lbfgsb
  module_function

  # Minimize a function using the L-BFGS-B algorithm.
  #
  # @param fnc [Method/Proc] Method for calculating the function to be minimized.
  # @param x_init [Numo::DFloat] (shape: [n_elements]) Initial point.
  # @param jcb [Method/Proc] Method for calculating the gradient vector.
  # @param args [Array/Hash] Arguments pass to the 'fnc' and 'jcb'.
  # @param bounds [Numo::DFloat/Nil] (shape: [n_elements, 2])
  #   \[lower, upper\] bounds for each element x. If nil is given, x is unbounded.
  # @param factr [Float] The iteration will be stop when
  #
  #   `(f^k - f^\{k+1\})/max{|f^k|,|f^\{k+1\}|,1} <= factr * Lbfgsb::DBL_EPSILON`
  #
  #   Typical values for factr: 1e12 for low accuracy; 1e7 for moderate accuracy; 1e1 for extremely high accuracy.
  # @param pgtol [Float] The iteration will be stop when
  #
  #   `max{|pg_i| i = 1, ..., n} <= pgtol`
  #
  #   where pg_i is the ith component of the projected gradient.
  # @param maxcor [Integer] The maximum number of variable metric corrections used to define the limited memory matrix.
  # @param maxiter [Integer] The maximum number of iterations.
  # @param verbose [Integer/Nil] If negative value or nil is given, no display output is generated.
  def minimize(fnc:, x_init:, jcb:, args: nil, bounds: nil, factr: 1e7, pgtol: 1e-5, maxcor: 10, maxiter: 15_000, verbose: nil)
    n_elements = x_init.size
    l = Numo::DFloat.zeros(n_elements)
    u = Numo::DFloat.zeros(n_elements)
    nbd = Numo::Int64.zeros(n_elements)

    unless bounds.nil?
      n_elements.times do |n|
        lower = bounds[n, 0]
        upper = bounds[n, 1]
        l[n] = lower
        u[n] = upper
        if lower.finite? && !upper.finite?
          nbd[n] = 1
        elsif lower.finite? && upper.finite?
          nbd[n] = 2
        elsif !lower.finite? && upper.finite?
          nbd[n] = 3
        end
      end
    end

    min_l_bfgs_b(fnc, x_init, jcb, args, l, u, nbd, maxcor, factr, pgtol, maxiter, verbose)
  end

  private_class_method :min_l_bfgs_b
end
