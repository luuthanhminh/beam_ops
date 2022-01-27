fmt:
	for i in $$(find . -name \*.tf |grep -v "\.terraform"); do terraform fmt -write=true $$i; done
