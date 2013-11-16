// *************************************************** //
// Media Detail Page
//
// The media detail page is shown when a specific
// Instagram media item is displayed.
// The page has a number of features that can be
// applied to the media item as well as the user that
// uploaded it.
// *************************************************** //

// import blackberry components
import bb.cascades 1.2

// set import directory for components
import "../components"

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext
import "../classes/authenticationhandler.js" as Authentication

Page {
    id: mediaDetailPage

    // property containing the media data
    // this is filled by the calling page
    // image data is of type InstagramMediaData()
    property variant mediaData

    // main content container
    Container {
        // layout definition
        layout: DockLayout {
        }

        // make the whole content container scrollables
        ScrollView {
            id: loginInstagramWebViewScrollContainer
            scrollViewProperties {
                scrollMode: ScrollMode.Vertical
                pinchToZoomEnabled: false
            }

            // image content
            Container {
                id: mediaDetailContainer

                // set initial visibility to false
                visible: false

                // layout definition
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }

                // the actual thumbnail image
                InstagramImageView {
                    id: mediaDetailImage

                    // position and layout properties
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center

                    onImageDoubleClicked: {
                        mediaDetailLikeButton.pressButton();
                    }
                }

                // the like and comment button
                Container {
                    // layout definition
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }

                    // layout definition
                    topMargin: 1

                    // like button
                    // this also contains the full like functionalites
                    LikeButton {
                        id: mediaDetailLikeButton

                        // layout definition
                        rightMargin: 1

                        // position and layout properties
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }

                        // increase like count
                        onLikeAdded: {
                            mediaDetailLikeButton.count = parseInt(mediaDetailLikeButton.count) + 1;
                        }

                        // decrease like count
                        onLikeRemoved: {
                            mediaDetailLikeButton.count = parseInt(mediaDetailLikeButton.count) - 1;
                        }

                        onLongPress: {
                            // console.log("# Like button long pressed");
                            var mediaLikesPage = mediaLikesComponent.createObject();
                            mediaLikesPage.mediaData = mediaDetailPage.mediaData;
                            navigationPane.push(mediaLikesPage);
                        }
                    }

                    // comment button
                    // this also contains the full comment functionalites
                    CommentButton {
                        id: mediaDetailCommentButton

                        // position and layout properties
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }

                        // show / hide comment input component on press
                        onClicked: {
                            mediaDetailCommentInput.visible = ! mediaDetailCommentInput.visible;
                        }
                        
                        onLongPress: {
                            // console.log("# Like button long pressed");
                            var mediaCommentsPage = mediaCommentsComponent.createObject();
                            mediaCommentsPage.mediaData = mediaDetailPage.mediaData;
                            navigationPane.push(mediaCommentsPage);
                        }                        
                    }
                }

                CommentInput {
                    id: mediaDetailCommentInput

                    // layout definition
                    topMargin: 1

                    // set initial visibility to false
                    // will be set by comment button
                    visible: false

                    // change state of comment button if visibility of input has changed
                    onVisibleChanged: {
                        mediaDetailCommentButton.active = visible;
                    }

                    // add comment count
                    onCommentAdded: {
                        mediaDetailCommentButton.count = parseInt(mediaDetailCommentButton.count) + 1;
                        mediaDetailCommentPreview.update();
                        mediaDetailCommentButton.visible = true;
                    }
                }

                // the image description
                // this contains user profile image, name and image caption
                MediaDescription {
                    id: mediaDetailMediaDescription

                    // layout definition
                    topMargin: 1

                    onClicked: {
                        // console.log("# Item clicked: " + mediaData.userData.userId);
                        var userDetailPage = userDetailComponent.createObject();
                        userDetailPage.userData = mediaData.userData;
                        navigationPane.push(userDetailPage);
                    }
                }

                // image location
                LocationMap {
                    id: mediaDetailLocation

                    // layout definition
                    topMargin: 1

                    // set initial visibility to false
                    // will be set true if the image has location data
                    visible: false
                }

                // comment previews
                CommentPreview {
                    id: mediaDetailCommentPreview

                    // layout definition
                    topMargin: 1

                    // set specific height for component
                    // otherwise the height will be too great for some reason
                    preferredHeight: 620

                    // set initial visibility to false
                    visible: false

                    onClicked: {
                        if (Authentication.auth.isAuthenticated()) {
                        }
                    }
                }
            }

            // check if Q series device and item is scrolled at all
            // if so, then hide / show the action bar
            onViewableAreaChanged: {
                if (DisplayInfo.height < 900)
                    if (viewableArea.y > 20) {
                    mediaDetailPage.actionBarVisibility = ChromeVisibility.Default;
                } else {
                    mediaDetailPage.actionBarVisibility = ChromeVisibility.Hidden;
                }
            }
        }

        LoadingIndicator {
            id: loadingIndicator
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }

        InfoMessage {
            id: infoMessage
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }
    }

    // page creation is finished
    // this prepares the general state of the page
    // the page waits for an external page to fill the mediaData property
    onCreationCompleted: {
        // console.log("# Creation of media detail page finished");

        // hide action bar if Q series device
        if (DisplayInfo.height < 900) {
            // console.log("# Display height is < 900, hiding action bar")
            actionBarVisibility:
            ChromeVisibility.Hidden;
        }

        // show loader
        loadingIndicator.showLoader("Loading media data");
    }

    // mediaData property was changed y an external page
    // fill the detail component with the given content
    onMediaDataChanged: {
        // hide loader
        loadingIndicator.hideLoader();

        // main image
        mediaDetailContainer.visible = true;
        mediaDetailImage.url = mediaData.mediaStandardImage;

        // image description (profile picture, name and image description)
        mediaDetailMediaDescription.userimage = mediaData.userData.profilePicture;
        mediaDetailMediaDescription.username = mediaData.userData.username;
        mediaDetailMediaDescription.imagecaption = mediaData.caption;

        // likes + comments
        mediaDetailLikeButton.count = mediaData.numberOfLikes;
        mediaDetailCommentButton.count = mediaData.numberOfComments;
        mediaDetailLikeButton.mediaId = mediaData.mediaId;
        if (mediaData.userHasLiked !== undefined) {
            mediaDetailLikeButton.userHasLiked = mediaData.userHasLiked;
        }

        // if the image has comments, show them in the preview component
        if (mediaData.commentData.length > 0) {
            mediaDetailCommentPreview.addToGallery(mediaData.commentData);
            mediaDetailCommentPreview.visible = true;
            mediaDetailCommentPreview.mediaId = mediaData.mediaId;
        }

        // if the image has a location, show it in the location map component
        if (mediaData.locationName != "") {
            mediaDetailLocation.latitude = mediaData.locationLatitude;
            mediaDetailLocation.longitude = mediaData.locationLongitude;
            mediaDetailLocation.altitude = 1500;
            mediaDetailLocation.pinText = mediaData.locationName;
            mediaDetailLocation.visible = true;
        }
    }

    // attach components
    attachedObjects: [
        // user detail page
        // will be called if user clicks on user description
        ComponentDefinition {
            id: userDetailComponent
            source: "UserDetail.qml"
        },
        // media comments page
        // will be called if user long presses on comment button
        ComponentDefinition {
            id: mediaCommentsComponent
            source: "MediaComments.qml"
        },
        // media likes page
        // will be called if user long presses on like button
        ComponentDefinition {
            id: mediaLikesComponent
            source: "MediaLikes.qml"
        }
    ]
}
