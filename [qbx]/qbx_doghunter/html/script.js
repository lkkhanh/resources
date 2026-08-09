const container = document.getElementById('minigame-container');
const arrowContainer = document.getElementById('arrow-container');
const timerBar = document.getElementById('timer-bar');
const roundCountEl = document.getElementById('round-count');

let isPlaying = false;
let currentSequence = [];
let currentIndex = 0;
let roundsCompleted = 0;
const totalRounds = 10;
const timePerRound = 4000; // 4 seconds
let timerInterval;
let startTime;

const arrowMap = {
    'ArrowUp': '↑',
    'ArrowDown': '↓',
    'ArrowLeft': '←',
    'ArrowRight': '→'
};
const keys = Object.keys(arrowMap);

window.addEventListener('message', function (event) {
    if (event.data.action === 'startMinigame') {
        startMinigame();
    }
});

function startMinigame() {
    container.style.display = 'block';
    isPlaying = true;
    roundsCompleted = 0;
    roundCountEl.innerText = roundsCompleted;
    nextRound();
}

function nextRound() {
    if (roundsCompleted >= totalRounds) {
        endGame(true);
        return;
    }

    currentIndex = 0;
    currentSequence = [];
    arrowContainer.innerHTML = '';

    // Random length 4 to 6
    const seqLength = Math.floor(Math.random() * 3) + 4;

    for (let i = 0; i < seqLength; i++) {
        const randomKey = keys[Math.floor(Math.random() * keys.length)];
        currentSequence.push(randomKey);

        const arrowDiv = document.createElement('div');
        arrowDiv.classList.add('arrow');
        arrowDiv.innerText = arrowMap[randomKey];
        if (i === 0) arrowDiv.classList.add('active');
        arrowContainer.appendChild(arrowDiv);
    }

    startTimer();
}

function startTimer() {
    clearInterval(timerInterval);
    startTime = Date.now();
    timerBar.style.transition = 'none'; // tắt hiệu ứng để bơm đầy ngay lập tức
    timerBar.style.width = '100%';
    
    // Ép trình duyệt cập nhật giao diện (reflow) ngay lập tức
    void timerBar.offsetWidth; 

    // Bật lại hiệu ứng chạy tụt thời gian
    timerBar.style.transition = `width ${timePerRound}ms linear`;
    timerBar.style.width = '0%';

    timerInterval = setInterval(() => {
        if (Date.now() - startTime >= timePerRound) {
            clearInterval(timerInterval);
            endGame(false); // timeout
        }
    }, 50);
}

window.addEventListener('keydown', function (e) {
    if (!isPlaying) return;

    // Prevent default scrolling for arrows
    if (keys.includes(e.key)) {
        e.preventDefault();
    } else {
        return; // Ignore non-arrow keys
    }

    const expectedKey = currentSequence[currentIndex];
    const arrowElements = arrowContainer.children;

    if (e.key === expectedKey) {
        // Correct key
        arrowElements[currentIndex].classList.remove('active');
        arrowElements[currentIndex].classList.add('success');

        currentIndex++;

        if (currentIndex < currentSequence.length) {
            arrowElements[currentIndex].classList.add('active');
        } else {
            // Sequence completed
            clearInterval(timerInterval);
            roundsCompleted++;
            roundCountEl.innerText = roundsCompleted;
            setTimeout(nextRound, 200); // small delay for visual feedback
        }
    } else {
        // Wrong key
        arrowElements[currentIndex].classList.remove('active');
        arrowElements[currentIndex].classList.add('fail');
        clearInterval(timerInterval);
        setTimeout(() => endGame(false), 300); // Show red briefly before ending
    }
});

function endGame(success) {
    isPlaying = false;
    clearInterval(timerInterval);
    container.style.display = 'none';

    fetch(`https://${GetParentResourceName()}/minigameResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ success: success })
    }).catch(() => { });
}
