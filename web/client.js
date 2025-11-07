var pc = null;

function negotiate() {
    pc.addTransceiver('video', { direction: 'recvonly' });
    pc.addTransceiver('audio', { direction: 'recvonly' });
    return pc.createOffer().then((offer) => {
        return pc.setLocalDescription(offer);
    }).then(() => {
        // wait for ICE gathering to complete
        return new Promise((resolve) => {
            if (pc.iceGatheringState === 'complete') {
                resolve();
            } else {
                const checkState = () => {
                    if (pc.iceGatheringState === 'complete') {
                        pc.removeEventListener('icegatheringstatechange', checkState);
                        resolve();
                    }
                };
                pc.addEventListener('icegatheringstatechange', checkState);
            }
        });
    }).then(() => {
        var offer = pc.localDescription;
        return fetch('/offer', {
            body: JSON.stringify({
                sdp: offer.sdp,
                type: offer.type,
            }),
            headers: {
                'Content-Type': 'application/json'
            },
            method: 'POST'
        });
    }).then((response) => {
        return response.json();
    }).then((answer) => {
        document.getElementById('sessionid').value = answer.sessionid
        return pc.setRemoteDescription(answer);
    }).catch((e) => {
        alert(e);
    });
}

function start() {
    var config = {
        sdpSemantics: 'unified-plan'
    };

    if (document.getElementById('use-stun').checked) {
        config.iceServers = [{ urls: ['stun:stun.miwifi.com:3478'] }];
    }

    pc = new RTCPeerConnection(config);

    // connect audio / video
    pc.addEventListener('track', (evt) => {
        console.log('收到媒体轨道:', evt.track.kind);
        if (evt.track.kind == 'video') {
            var videoElement = document.getElementById('video');
            if (videoElement) {
                videoElement.srcObject = evt.streams[0];
                console.log('视频流已设置到 video 元素');
                
                // 监听视频元数据加载
                videoElement.onloadedmetadata = function() {
                    console.log('视频元数据已加载');
                    console.log('视频尺寸:', videoElement.videoWidth, 'x', videoElement.videoHeight);
                    console.log('视频是否暂停:', videoElement.paused);
                    console.log('视频就绪状态:', videoElement.readyState);
                    
                    // 尝试播放
                    videoElement.play().then(() => {
                        console.log('✅ 视频播放成功（静音模式）');
                        console.log('💡 提示：点击页面任意位置即可开启声音');
                    }).catch(err => {
                        console.error('❌ 视频播放失败:', err);
                    });
                };
            } else {
                console.error('找不到 video 元素');
            }
        } else {
            var audioElement = document.getElementById('audio');
            if (audioElement) {
                audioElement.srcObject = evt.streams[0];
                console.log('音频流已设置到 audio 元素');
            } else {
                console.log('没有独立的 audio 元素，音频将通过 video 元素播放');
            }
        }
    });

    // 隐藏/显示按钮（如果存在）
    var startBtn = document.getElementById('start');
    var stopBtn = document.getElementById('stop');
    if (startBtn) startBtn.style.display = 'none';
    if (stopBtn) stopBtn.style.display = 'inline-block';
    
    negotiate();
}

function stop() {
    var stopBtn = document.getElementById('stop');
    if (stopBtn) stopBtn.style.display = 'none';

    // close peer connection
    setTimeout(() => {
        if (pc) pc.close();
    }, 500);
}

window.onunload = function(event) {
    // 在这里执行你想要的操作
    setTimeout(() => {
        pc.close();
    }, 500);
};

window.onbeforeunload = function (e) {
        setTimeout(() => {
                pc.close();
            }, 500);
        e = e || window.event
        // 兼容IE8和Firefox 4之前的版本
        if (e) {
          e.returnValue = '关闭提示'
        }
        // Chrome, Safari, Firefox 4+, Opera 12+ , IE 9+
        return '关闭提示'
      }