# Install

### 1. Follow this tutorial

https://k2-fsa.github.io/sherpa/onnx/ios/build-sherpa-onnx-swift.html#requirement

Output: `/build-ios`

### 2. Download models & unzip into `/models` folder:

https://drive.google.com/drive/folders/1onN3u_OqvX654oBUqYF3luWa94ASHKdS?usp=drive_link

### 3. Open `ios-swift` folder, open in Xcode.

### 4. Run and build

### 5. Notes

If encounting error: 

**Git error: RPC failed; HTTP 400 curl 22 The requested URL returned error: 400 send-pack: unexpected disconnect while reading sideband packet**

Fix: https://stackoverflow.com/questions/77856025/git-error-rpc-failed-http-400-curl-22-the-requested-url-returned-error-400-se

Run command: `git config http.postBuffer 524288000`