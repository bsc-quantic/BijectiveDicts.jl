# BijectiveDicts.jl

A tiny Julia package that provides the `BijectiveDict` type: a one-to-one `AbstractDict` between keys and values.

In order to construct a `BijectiveDict`, you must pass the forward and inverse dictionaries:

```julia
julia> d = Dict(:a => 1, :b => 2)
Dict{Symbol, Int64} with 2 entries:
  :a => 1
  :b => 2

julia> dinv = Dict(1 => :a, 2 => :b)
Dict{Int64, Symbol} with 2 entries:
  2 => :b
  1 => :a

julia> bd = BijectiveDict(d, dinv)
BijectiveDict{Symbol,Int64} with 2 entries:
  :a => 1
  :b => 2
```

Altenatively, you can pass only the forward dictionary and it will automatically generate the inverse dictionary (or fail if the dictionary is not a one-to-one mapping).

```julia
julia> bd = BijectiveDict(d)
BijectiveDict{Symbol,Int64} with 2 entries:
  :a => 1
  :b => 2
```

It implements the `AbstractDict` interface and exports a `hasvalue` function that acts like `Base.haskey` but on values. This is as performant as `Base.haskey` because it just calls `haskey` on the inverse dictionary.

```julia
julia> bd[:a]
1

julia> bd[:c] = 3
3

julia> bd
BijectiveDict{Symbol,Int64} with 3 entries:
  :a => 1
  :b => 2
  :c => 3

julia> julia> keys(bd)
KeySet for a Dict{Symbol, Int64} with 3 entries. Keys:
  :a
  :b
  :c

julia> values(bd)
ValueIterator for a Dict{Symbol, Int64} with 3 entries. Values:
  1
  2
  3

julia> get(bd, :k, "not an entry")
"not an entry"

julia> delete!(bd, :c)
BijectiveDict{Symbol,Int64} with 2 entries:
  :a => 1
  :b => 2
```

In order to get the inverse mapping, you can use `Base.adjoint`. Note that in order to be performant, it returns a view to the same dictionaries without copying. Mutating the adjoint `BijectiveDict` mutates the original one too, and that's the way it's used.

```julia
julia> bd'
BijectiveDict{Int64,Symbol} with 2 entries:
  2 => :b
  1 => :a

julia> bd'[1]
:a

julia> bd'[3] = :c
:c

julia> bd
BijectiveDict{Symbol,Int64} with 3 entries:
  :a => 1
  :b => 2
  :c => 3
```

One of the bigest differences with [`Bijections.jl`](https://github.com/scheinerman/Bijections.jl) is that `BijectiveDict` parameterizes the dictionaries underneath, so you can choose to use different dictionary types for both forward and inverse dictionaries.

```julia
julia> d = Dict(:a => a, :b => b)
Dict{Symbol, Vector{Int64}} with 2 entries:
  :a => [1, 0]
  :b => [0, 1]

julia> dinv = IdDict(a => :a, b => :b)
IdDict{Vector{Int64}, Symbol} with 2 entries:
  [1, 0] => :a
  [0, 1] => :b

julia> bd = BijectiveDict(d, dinv)
BijectiveDict{Symbol,Vector{Int64}} with 2 entries:
  :a => [1, 0]
  :b => [0, 1]

julia> hasvalue(bd, a)
true

julia> hasvalue(bd, copy(a))
false
```

<details>
<summary>Codegen comparison of <code>setindex!</code> on regular vs adjoint <code>BijectiveDict</code></summary>

There is no performance overhead of calling `setindex!` on the regular `BijectiveDict` or on its `adjoint`. Both lead to the same LLVM IR and assembly code.

## `setindex!`

```julia
julia> @code_llvm bd[:a]
; Function Signature: getindex(BijectiveDicts.BijectiveDict{Symbol, Int64, Base.Dict{Symbol, Int64}, Base.Dict{Int64, Symbol}}, Symbol)
;  @ /Users/mofeing/.julia/packages/BijectiveDicts/Lx2EW/src/BijectiveDicts.jl:46 within `getindex`
define i64 @julia_getindex_16696(ptr nocapture noundef nonnull readonly align 8 dereferenceable(16) %"bd::BijectiveDict", ptr noundef nonnull %"key::Symbol") #0 {
top:
; ┌ @ Base.jl:49 within `getproperty`
   %"bd::BijectiveDict.f" = load atomic ptr, ptr %"bd::BijectiveDict" unordered, align 8
; └
  %0 = call i64 @j_getindex_16700(ptr nonnull %"bd::BijectiveDict.f", ptr nonnull %"key::Symbol")
  ret i64 %0
}
```

## `setindex!` on `adjoint`

```julia
julia> @code_llvm bd'[1]
; Function Signature: getindex(BijectiveDicts.BijectiveDict{Int64, Symbol, Base.Dict{Int64, Symbol}, Base.Dict{Symbol, Int64}}, Int64)
;  @ /Users/mofeing/.julia/packages/BijectiveDicts/Lx2EW/src/BijectiveDicts.jl:46 within `getindex`
define nonnull ptr @julia_getindex_16701(ptr nocapture noundef nonnull readonly align 8 dereferenceable(16) %"bd::BijectiveDict", i64 signext %"key::Int64") #0 {
top:
; ┌ @ Base.jl:49 within `getproperty`
   %"bd::BijectiveDict.f" = load atomic ptr, ptr %"bd::BijectiveDict" unordered, align 8
; └
  %0 = call nonnull ptr @j_getindex_16705(ptr nonnull %"bd::BijectiveDict.f", i64 signext %"key::Int64")
  ret ptr %0
}
```

</details>
