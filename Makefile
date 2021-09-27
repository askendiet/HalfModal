.PHONY: generate-xcodeproj
generate-xcodeproj: 
	swift package generate-xcodeproj

.PHONY: rm-xcodeproj
rm-xcodeproj:
	rm -rf HalfModal.xcodeproj	