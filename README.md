
## OVERVIEW

This is a native iOS Messenger app, making realtime chat conversations and audio calls with full offline support.


- Audio call (in-app voice calling over a data connection)
- Message queue (creating new messages while offline)
- Switch between multiple accounts
- Media donwload network settings (Wi-Fi, Cellular or Manual)
- Cache settings for media messages (automatic/manual cleanup)
- Auto save media option
- Media message re-download option
- Dynamic password generation
- Full source code is available for all feature

## KEY FEATURES

- Firebase backend (full realtime actions)
- Realm local database (full offline availability)
- AES-256 encryption

## FEATURES

- Live chat between multiple devices
- Group chat functionality
- Private chat functionality
- Single or Multiple recipients
- Push notification support
- No backend programming is needed
- Native and easy to customize user interface
- Login with Email
- Login with Facebook
- Sending text messages
- Sending pictures
- Sending videos
- Sending audio messages
- Sending current location
- Sending stickers
- Sending large emojis
- MD5 checksum for media messages
- Media file local cache
- Load earlier messages
- Typing indicator
- Message delivery receipt
- Message read receipt
- Save picture messages to device
- Save video messages to device
- Save audio messages to device
- Delete read and unread messages
- Realtime recent view for ongoing chats
- Archived conversation view for archived chats
- Map view for shared locations
- Picture view for pictures
- Basic Settings view included
- Basic Profile view for users
- Edit Profile view for changing user details
- Onboarding view on signup
- Group details view for groups
- Chat details view
- Privacy Policy view
- Terms of Service view
- Picture, video and audio upload progress indicator
- Video length limit possibility
- Copy and paste text messages
- Arbitrary message sizes
- Data detectors - phone numbers, links, dates
- Send/Receive sound effects
- Deployment target: iOS 9.3+
- Supported devices: iPhone 4S/5/5C/5S/5SE/6/6 Plus/6S/6S Plus/7/7 Plus


## REQUIREMENTS

- Xcode 8.1+
- iOS 9.3+
- ARC

## INSTALLATION

**1.,** Please run `pod install` first (the CocoaPods Frameworks and Libraries are not included in the repo). If you haven't used CocoaPods before, you can get started [here](https://guides.cocoapods.org/using/getting-started.html). You might prefer to use the [CocoaPods app](https://cocoapods.org/app) instead of the command line tool.

**2.,** Please make an account at [Firebase](https://firebase.google.com) and perform some very basic [setup](https://firebase.google.com/docs/ios/setup).

**3.,** Please download `GoogleService-Info.plist` from Firebase and replace the existing file in your Xcode project.

**4.,** Please replace the `FIREBASE_STORAGE` define value in `AppConstant.h`.

**5.,** For using push notification feature, please create an account at [OneSignal](https://onesignal.com). You will need to [configure](https://documentation.onesignal.com/docs/generating-an-ios-push-certificate) your certificate details.

**6.,** Please replace the `ONESIGNAL_APPID` define value in `AppConstant.h`.

**7.,** For using audio call feature, please create an account at [Sinch](https://www.sinch.com).

**8.,** Please replace the `SINCH_KEY` and `SINCH_SECRET` define values in `AppConstant.h`.

**9.,** In case of using Facebook login, please register your app at [Facebook](https://developers.facebook.com/apps).

**10.,** Then please replace the existing Facebook account details in `Info.plist`.

## CONTACT

my email is ryan039@outlook.com

## LICENSE

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
