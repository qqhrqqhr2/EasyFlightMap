# 릴리즈 / Releasing

CurseForge 프로젝트 ID / Project ID: **1736991**

## 한국어

1. 이 폴더의 내용을 GitHub 저장소 루트에 넣습니다.
2. 저장소 Settings → Secrets and variables → Actions에서 `CF_API_KEY` 시크릿에 CurseForge 업로드 API 키를 등록합니다. 키는 소스 코드에 넣지 않습니다.
3. `EasyFlightMap.toc`의 Version과 `CHANGELOG.md`의 최신 `## X.Y.Z` 버전을 일치시킵니다.
4. main에 CHANGELOG 변경을 푸시하면 해당 버전 태그를 만들고 태그 기준 릴리즈 작업을 실행합니다. Actions에서 Release를 수동 실행해도 됩니다.
5. 태그 실행은 BigWigsMods/packager로 GitHub 릴리즈와 CurseForge 파일 업로드를 수행합니다. 완료 여부는 Actions 로그와 CurseForge 파일 상태에서 확인합니다.

이미 존재하는 릴리즈는 다시 게시하지 않으며, 다른 커밋을 가리키는 기존 태그는 덮어쓰지 않습니다. 문서와 대표 이미지, 워크플로는 게임 설치 ZIP에서 제외합니다. 프로젝트 페이지의 아이콘과 설명은 별도로 등록합니다.

## English

1. Place this folder's contents at the root of the GitHub repository.
2. Add your CurseForge upload API key as the `CF_API_KEY` Actions repository secret. Never put the key in source files.
3. Keep the TOC Version and the latest `## X.Y.Z` CHANGELOG heading in sync.
4. Pushing a CHANGELOG change to main creates the version tag and dispatches a release at that tag. You can also run Release manually in Actions.
5. The tagged workflow uses BigWigsMods/packager to publish a GitHub release and upload the addon to CurseForge. Check Actions logs and the CurseForge file status for completion.

Existing releases are skipped, and tags pointing to another commit are never overwritten. Documentation, project artwork, and workflows are excluded from the install ZIP. Upload the project icon and description separately.
