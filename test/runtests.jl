using Test
using BijectiveDicts

# Test empty constructor
function test_empty_constructor()
    bd = BijectiveDict{Int,String}()
    @test length(bd) == 0
end

# Test constructor with arguments
function test_constructor_with_args()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test length(bd) == 2
    @test bd[1] == "one"
    @test bd[2] == "two"
end

# Test adjoint function
function test_adjoint()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    adj_bd = adjoint(bd)
    @test length(adj_bd) == 2
    @test adj_bd["one"] == 1
    @test adj_bd["two"] == 2
end

# Test copy function
function test_copy()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    bd_copy = copy(bd)
    @test length(bd_copy) == 2
    @test bd_copy[1] == "one"
    @test bd_copy[2] == "two"
end

# Test empty function
function test_empty()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    empty_bd = empty(bd)
    @test length(empty_bd) == 0
end

# Test getindex function
function test_getindex()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test bd[1] == "one"
    @test bd[2] == "two"
end

# Test setindex! function
function test_setindex()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    setindex!(bd, "three", 3)
    @test length(bd) == 3
    @test bd[3] == "three"
    @test adjoint(bd)["three"] == 3
end

# Test get function
function test_get()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test get(bd, 1, "default") == "one"
    @test get(bd, 3, "default") == "default"
end

# Test sizehint! function
function test_sizehint()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    nslots = length(bd.f.slots)
    sizehint!(bd, nslots + 1)
    @test length(bd) == 2
    @test length(bd.f.slots) > nslots
end

# Test iterate function
function test_iterate()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test issetequal(collect(bd), [1 => "one", 2 => "two"])
end

# Test keys function
function test_keys()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test issetequal(keys(bd), [1, 2])
    @test issetequal(keys(bd'), ["one", "two"])
end

# Test values function
function test_values()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test issetequal(values(bd), ["one", "two"])
    @test issetequal(values(bd'), [1, 2])
end

# Test haskey function
function test_haskey()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    @test haskey(bd, 1)
    @test !haskey(bd, 3)
end

# Test delete! function
function test_delete!()
    bd = BijectiveDict{Int,String}(1 => "one", 2 => "two")
    delete!(bd, 1)
    @test !haskey(bd, 1)
    @test !haskey(bd', "one")
end

# Test all functions
@testset "Unit tests" begin
    test_empty_constructor()
    test_constructor_with_args()
    test_adjoint()
    test_copy()
    test_empty()
    test_getindex()
    test_setindex()
    test_get()
    test_sizehint()
    test_iterate()
    test_keys()
    test_values()
    test_haskey()
    test_delete!()
end