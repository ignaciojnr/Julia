import Base.Threads.@spawn


const N = 2^28
const RANGO_MINIMO = 8

#
function InsertionSort!(vector::Array{Int16,1}, lo::Int, hi::Int)
    @inbounds for i = lo+1:hi
        j = i
        x = vector[i]
        while j > lo
            if x < vector[j-1]
                vector[j] = vector[j-1]
                j -= 1
                continue
            end
            break
        end
        vector[j] = x
    end
    return vector
end


#
function MergeSortSerial!(vector::Array{Int16,1}, lo::Int, hi::Int, t=similar(v,0))
    @inbounds if lo < hi
        hi-lo <= RANGO_MINIMO && return InsertionSort!(vector, lo, hi)

        m = div(lo+hi,2)
        isempty(t) && resize!(t, m-lo+1)

        MergeSortSerial!(vector, lo,  m, t)
        MergeSortSerial!(vector, m+1, hi, t)

	m = div(lo+hi,2)

	i, j = 1, lo
	while j <= m
	    t[i] = vector[j]
	    i += 1
	    j += 1
	end

	i, k = 1, lo
	while k < j <= hi
	    if vector[j] < t[i]
		vector[k] = v[j]
		j += 1
	    else
		vector[k] = t[i]
		i += 1
	    end
	    k += 1
	end
	while k < j
	    vector[k] = t[i]
	    k += 1
	    i += 1
	end
    end

    return vector
end

function MergeSortSpawn!(vector::Array{Int16,1}, lo::Int, hi::Int)
    x = vector[lo:hi]
    MergeSortSerial!(x, lo, hi)
    return x
end

#
function MergeSort!(vector::Array{Int16,1}, lo::Int, hi::Int)
    @inbounds if lo < hi
        hi-lo <= RANGO_MINIMO && return InsertionSort!(vector, lo, hi)

        m = div(lo+hi,2)
        r = @spawn MergeSortSpawn!(vector, lo,  m)
        MergeSortSerial!(vector, m+1, hi)
	newt = fetch(r)
	m = div(lo+hi,2)
	j = m+1
	i, k = 1, lo
	while k < j <= hi
	    if vector[j] < newt[i]
		vector[k] = vector[j]
		j += 1
	    else
		vector[k] = newt[i]
		i += 1
	    end
	    k += 1
	end
	while k < j
	    vector[k] = newt[i]
	    k += 1
	    i += 1
	end
    end

    return vector
end


function sort!(A::Array{Int16,1})
    MergeSort!(A, 1, length(A))
end


arreglo = Vector(rand(Int16,N))
time = @elapsed sort!(arreglo)
#println(arreglo)
print("\n")
println(time)
