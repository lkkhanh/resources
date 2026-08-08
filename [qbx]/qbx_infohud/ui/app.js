window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "show") {
        document.getElementById('app').style.display = "block";
    } else if (data.action === "hide") {
        document.getElementById('app').style.display = "none";
    } else if (data.action === "update") {
        if (data.players !== undefined) {
            document.getElementById('players').innerText = data.players;
        }
        if (data.id !== undefined) {
            document.getElementById('id').innerText = "#" + data.id;
        }
        if (data.street !== undefined) {
            document.getElementById('street').innerText = data.street;
        }
        if (data.cash !== undefined) {
            document.getElementById('cash').innerText = data.cash.toLocaleString('en-US') + "$";
        }
        if (data.bank !== undefined) {
            document.getElementById('bank').innerText = data.bank.toLocaleString('en-US') + "$";
        }
    } else if (data.action === "updatemoney") {
        let elId = data.type === 'cash' ? 'cash-update' : 'bank-update';
        let el = document.getElementById(elId);
        
        if (el) {
            // Reset animation
            el.classList.remove('plus', 'minus');
            void el.offsetWidth; // Trigger reflow để animation có thể chạy lại ngay lập tức
            
            if (data.minus) {
                el.innerText = "-" + data.amount.toLocaleString('en-US') + "$";
                el.classList.add('minus');
            } else {
                el.innerText = "+" + data.amount.toLocaleString('en-US') + "$";
                el.classList.add('plus');
            }
        }
    }
});
