module BijectiveDicts

export BijectiveDict, BijectiveIdDict

struct BijectiveDict{K,V,F<:AbstractDict{K,V},F⁻¹<:AbstractDict{V,K}} <: AbstractDict{K,V}
    f::F
    f⁻¹::F⁻¹

    BijectiveDict(f::F, f⁻¹::F⁻¹) where {K,V,F<:AbstractDict{K,V},F⁻¹<:AbstractDict{V,K}} = new{K,V,F,F⁻¹}(f, f⁻¹)
    BijectiveDict{K,V,F,F⁻¹}(f::F, f⁻¹::F⁻¹) where {K,V,F<:AbstractDict{K,V},F⁻¹<:AbstractDict{V,K}} = new{K,V,F,F⁻¹}(f, f⁻¹)
end

BijectiveDict(f::F) where {F<:AbstractDict} = BijectiveDict(f, dict_adjoint(f))
BijectiveDict{K,V,F,F⁻¹}(pairs::Pair...) where {K,V,F,F⁻¹} = BijectiveDict{K,V,F,F⁻¹}(F(pairs...), F⁻¹(Iterators.map(reverse, pairs)))
BijectiveDict{K,V,F,F⁻¹}(pairs::Vector{<:Pair}) where {K,V,F,F⁻¹} = BijectiveDict{K,V,F,F⁻¹}(F(pairs...), F⁻¹(Iterators.map(reverse, pairs)))

# F, F⁻¹ default to Dict
BijectiveDict{K,V}(args...; kwargs...) where {K,V} = BijectiveDict{K,V,Dict{K,V},Dict{V,K}}(args...; kwargs...)

const BijectiveIdDict{K,V} = BijectiveDict{K,V,IdDict{K,V},IdDict{V,K}}

dict_adjoint(D::Type{<:AbstractDict{K,V}}) where {K,V} = D.name.wrapper{V,K}
function dict_adjoint(d::D) where {D<:AbstractDict}
    allunique(values(d)) || throw(ArgumentError("dict is not bijective"))
    dict_adjoint(D)(Iterators.map(reverse, d))
end

Base.copy(bd::BijectiveDict) = BijectiveDict(copy(bd.f), copy(bd.f⁻¹))
function Base.empty(bd::BijectiveDict, ::Type{K}, ::Type{V}) where {K,V}
    BijectiveDict(empty(bd.f, K, V), empty(bd.f⁻¹, V, K))
end

Base.adjoint(::Type{BijectiveDict{K,V,F,F⁻¹}}) where {K,V,F,F⁻¹} = BijectiveDict{V,K,F⁻¹,F}
Base.adjoint(bd::BD) where {BD<:BijectiveDict} = BD'(bd.f⁻¹, bd.f)

Base.length(bd::BijectiveDict) = length(bd.f)

Base.summary(io::IO, bd::BijectiveDict{K,V}) where {K,V} = print(io, "BijectiveDict{$K,$V} with $(length(bd)) entries")

Base.haskey(bd::BijectiveDict, key) = haskey(bd.f, key)
inv_haskey(bd::BijectiveDict, key) = haskey(bd.f⁻¹, key)
hasvalue(bd::BijectiveDict, value) = inv_haskey(bd, value)
Base.keys(bd::BijectiveDict) = keys(bd.f)
Base.values(bd::BijectiveDict) = values(bd.f)

Base.getindex(bd::BijectiveDict{K,V}, key::K) where {K,V} = getindex(bd.f, key)
function Base.setindex!(bd::BijectiveDict{K,V}, value::V, key::K) where {K,V}
    haskey(bd.f⁻¹, value) && throw(ArgumentError("inserting $key => $value would break bijectiveness"))
    bd.f[key] = value
    bd.f⁻¹[value] = key
end

Base.iterate(bd::BijectiveDict) = iterate(bd.f)
Base.iterate(bd::BijectiveDict, s) = iterate(bd.f, s)

Base.get(bd::BijectiveDict, key, default) = get(bd.f, key, default)

function Base.sizehint!(bd::BijectiveDict, sz)
    sizehint!(bd.f, sz)
    sizehint!(bd.f⁻¹, sz)
    bd
end

function Base.delete!(bd::BijectiveDict, key)
    haskey(bd, key) || return bd
    value = bd.f[key]
    delete!(bd.f, key)
    delete!(bd.f⁻¹, value)
    return bd
end

end
