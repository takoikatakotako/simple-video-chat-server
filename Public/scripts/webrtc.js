const localVideo = document.getElementById('local_video');
const remoteVideo = document.getElementById('remote_video');
const textForSendSdp = document.getElementById('text_for_send_sdp');
const textToReceiveSdp = document.getElementById('text_for_receive_sdp');
let localStream = null;
let peerConnection = null;
let negotiationneededCounter = 0;
let isOffer = false;


window.onload = function() {
    //alert("ページが読み込まれました！");
};

// apiのファイルの階層を取得
let apiUrl = location.href;
console.log(apiUrl.substr(0, apiUrl.lastIndexOf( '/' ) + 1));
apiUrl = apiUrl.substr(0, apiUrl.lastIndexOf( '/' ) + 1);

// getで送れるようにSDP中のスペースとタブを変換
function convertSdpString(str) {
  return str.replace(/ /g, '<SPACE>').replace(/\r?\n/g, '<BR>');
}

// getで送れるようにSDP中のスペースとタブを変換
function unconvertSdpString(str) {
  return str.replace(/<SPACE>/g, ' ').replace(/<BR>/g, '\n');
}

// setOfferボタンが押されたら
function setOfferSDP() {
  var offerSdp = convertSdpString(textForSendSdp.value);
  $.ajax({
    url: apiUrl + 'set-offer.php',
    type: 'POST',
    data : {
      name : "onojun",
      offer_sdp : offerSdp
    },
    success: function(data){
        let json = JSON.parse(data);
        console.log(json);
        if (json['is_success']) {
          console.log('seted offer sdp.')
        } else {
          console.log('error');
        }
    },
    error: function(data) {
      console.log('set offer failed.')
      console.log(data);
      alert(data);
    }
  });
}

// readOfferボタンが押されたら
function readOfferSDP() {
  $.ajax({
    url: apiUrl + 'read-offer.php?name=onojun',
    type: 'GET',
    success: function(data){
        let json = JSON.parse(data);
        console.log(json);
        if (json['is_success']) {
          // textareaに表示
          textToReceiveSdp.value = unconvertSdpString(json['offer_sdp']);
          console.log('read offer sdp.')
        } else {
          console.log('error');
        }
    },
    error: function(data) {
      console.log('read offer sdp failed.')
      alert(data);
    }
  });
}

// setAnswerボタンが押されたら
function setAnswerSDP() {
  var answerSDP = convertSdpString(textForSendSdp.value);
  $.ajax({
    url: apiUrl + 'set-answer.php',
    type: 'POST',
    data : {
      name : "onojun",
      answer_sdp : answerSDP
    },
    success: function(data){
        let json = JSON.parse(data);
        console.log(json);
        if (json['is_success']) {
          console.log('seted answer sdp.')
        } else {
          console.log('error');
        }
    },
    error: function(data) {
      console.log('read answer sdp failed.')
      alert(data);
    }
  });

}

// readAnswerボタンが押されたら
function readAnswerSDP() {
  $.ajax({
    url: apiUrl + 'read-answer.php?name=onojun',
    type: 'GET',
    success: function(data){
        let json = JSON.parse(data);
        console.log(json);
        if (json['is_success']) {
          // textareaに表示
          textToReceiveSdp.value = unconvertSdpString(json['answer_sdp']);
          console.log('read answer sdp.')
        } else {
          console.log('error');
        }
    },
    error: function(data) {
      console.log('read answer sdp failed.')
      alert(data);
    }
  });
}

// getUserMediaでカメラ、マイクにアクセス
async function startVideo() {
    try{
        localStream = await navigator.mediaDevices.getUserMedia({video: true, audio: true});
        playVideo(localVideo,localStream);
        //alert('aaaa');
    } catch(err){
        console.error('mediaDevice.getUserMedia() error:', err);
    }
}

// Videoの再生を開始する
async function playVideo(element, stream) {
    element.srcObject = stream;
    await element.play();
    console.log('played');
    sleep(3000);
    // 5秒後にメッセージを表示
    console.log('5秒経過しました！');
}


// WebRTCを利用する準備をする
function prepareNewConnection(isOffer) {
    const pc_config = {"iceServers":[ {"urls":"stun:stun.webrtc.ecl.ntt.com:3478"} ]};
    const peer = new RTCPeerConnection(pc_config);

    // リモートのMediStreamTrackを受信した時
    peer.ontrack = evt => {
        console.log('-- peer.ontrack()');
        playVideo(remoteVideo, evt.streams[0]);
    };

    // ICE Candidateを収集したときのイベント
    peer.onicecandidate = evt => {
        if (evt.candidate) {
            console.log(evt.candidate);
        } else {
            console.log('empty ice event');
            sendSdp(peer.localDescription);
        }
    };

    // Offer側でネゴシエーションが必要になったときの処理
    peer.onnegotiationneeded = async () => {
        try {
            if(isOffer){
                if(negotiationneededCounter === 0){
                    let offer = await peer.createOffer();
                    console.log('createOffer() succsess in promise');
                    await peer.setLocalDescription(offer);
                    console.log('setLocalDescription() succsess in promise');
                    sendSdp(peer.localDescription);
                    negotiationneededCounter++;
                }
            }
        } catch(err){
            console.error('setLocalDescription(offer) ERROR: ', err);
        }
    };

    // ローカルのMediaStreamを利用できるようにする
    if (localStream) {
        console.log('Adding local stream...');
        localStream.getTracks().forEach(track => peer.addTrack(track, localStream));
    } else {
        console.warn('no local stream, but continue.');
    }

    return peer;
}

// 手動シグナリングのための処理を追加する
function sendSdp(sessionDescription) {
    console.log('---sending sdp ---');
    textForSendSdp.value = sessionDescription.sdp;
    textForSendSdp.focus();
    textForSendSdp.select();
}

// Connectボタンが押されたらWebRTCのOffer処理を開始
function connect() {
    if (! peerConnection) {
        console.log('make Offer');
        peerConnection = prepareNewConnection(true);
    }
    else {
        console.warn('peer already exist.');
    }
}

// Answer SDPを生成する
async function makeAnswer() {
    console.log('sending Answer. Creating remote session description...' );
    if (! peerConnection) {
        console.error('peerConnection NOT exist!');
        return;
    }
    try{
        let answer = await peerConnection.createAnswer();
        console.log('createAnswer() succsess in promise');
        await peerConnection.setLocalDescription(answer);
        console.log('setLocalDescription() succsess in promise');
        sendSdp(peerConnection.localDescription);
    } catch(err){
        console.error(err);
    }
}

// Receive remote SDPボタンが押されたらOffer側とAnswer側で処理を分岐
function onSdpText() {
    const text = textToReceiveSdp.value;
    if (peerConnection) {
        console.log('Received answer text...');
        const answer = new RTCSessionDescription({
            type : 'answer',
            sdp : text,
        });
        setAnswer(answer);
    }
    else {
        console.log('Received offer text...');
        const offer = new RTCSessionDescription({
            type : 'offer',
            sdp : text,
        });
        setOffer(offer);
    }
    textToReceiveSdp.value ='';
}

// Offer側のSDPをセットする処理
async function setOffer(sessionDescription) {
    if (peerConnection) {
        console.error('peerConnection alreay exist!');
    }
    peerConnection = prepareNewConnection(false);
    try{
        await peerConnection.setRemoteDescription(sessionDescription);
        console.log('setRemoteDescription(answer) succsess in promise');
        makeAnswer();
    } catch(err){
        console.error('setRemoteDescription(offer) ERROR: ', err);
    }
}

// Answer側のSDPをセットする場合
async function setAnswer(sessionDescription) {
    if (! peerConnection) {
        console.error('peerConnection NOT exist!');
        return;
    }
    try{
        await peerConnection.setRemoteDescription(sessionDescription);
        console.log('setRemoteDescription(answer) succsess in promise');
    } catch(err){
        console.error('setRemoteDescription(answer) ERROR: ', err);
    }
}
