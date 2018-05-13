function out = meanWeighted(seq,weight)

	out = sum(seq.*weight)/...
		  sum(weight); 			  	


end