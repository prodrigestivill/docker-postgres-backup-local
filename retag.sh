#!/bin/sh -e
TAGS="11 10 9.6 9.5 9.4"

git push --tags -f
git reset --hard
for TAG in $TAGS; do
	sed -i "1 s,\$,:${TAG}," Dockerfile-debian
	sed -i "1 s,:alpine\$,:${TAG}-alpine," Dockerfile-alpine
	git commit -m "Tag $TAG" Dockerfile-*
	git tag -f "$TAG" 
	# github events needs to push each tag separately
	git push --tags -f
	git reset HEAD^
	git reset --hard
done
