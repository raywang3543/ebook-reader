/**
 * 电子书阅读器应用
 * 功能：上传小说、识别章节、阅读导航、背景音乐、主题设置
 */

class EbookReader {
    constructor() {
        // 应用状态
        this.state = {
            bookName: '',
            chapters: [], // { title: string, content: string }
            currentChapter: 0,
            currentPage: 0,
            pagesPerChapter: [], // 每个章节的分页数
            fontSize: 18,
            theme: 'light',
            musicFile: null,
            isMusicPlaying: false,
            musicVolume: 0.5
        };

        // DOM 元素
        this.elements = {};

        // 初始化
        this.init();
    }

    /**
     * 初始化应用
     */
    init() {
        this.cacheElements();
        this.bindEvents();
        this.loadSettings();
        this.checkSavedProgress();
    }

    /**
     * 缓存 DOM 元素
     */
    cacheElements() {
        // 屏幕
        this.elements.welcomeScreen = document.getElementById('welcome-screen');
        this.elements.readerScreen = document.getElementById('reader-screen');

        // 上传
        this.elements.bookUpload = document.getElementById('book-upload');
        this.elements.musicUpload = document.getElementById('music-upload');
        this.elements.startReading = document.getElementById('start-reading');

        // 阅读器
        this.elements.bookTitle = document.getElementById('book-title');
        this.elements.chapterTitle = document.getElementById('chapter-title');
        this.elements.contentArea = document.getElementById('content-area');
        this.elements.pageInfo = document.getElementById('page-info');
        this.elements.prevPage = document.getElementById('prev-page');
        this.elements.nextPage = document.getElementById('next-page');
        this.elements.progressFill = document.getElementById('progress-fill');

        // 侧边栏
        this.elements.tocSidebar = document.getElementById('toc-sidebar');
        this.elements.settingsSidebar = document.getElementById('settings-sidebar');
        this.elements.tocList = document.getElementById('toc-list');
        this.elements.toggleToc = document.getElementById('toggle-toc');
        this.elements.toggleSettings = document.getElementById('toggle-settings');
        this.elements.closeToc = document.getElementById('close-toc');
        this.elements.closeSettings = document.getElementById('close-settings');

        // 设置
        this.elements.fontSizeSlider = document.getElementById('font-size-slider');
        this.elements.fontSizeValue = document.getElementById('font-size-value');
        this.elements.themeButtons = document.querySelectorAll('.theme-btn');
        this.elements.toggleMusic = document.getElementById('toggle-music');
        this.elements.volumeSlider = document.getElementById('volume-slider');
        this.elements.volumeValue = document.getElementById('volume-value');
        this.elements.clearData = document.getElementById('clear-data');

        // 音频
        this.elements.bgmPlayer = document.getElementById('bgm-player');
    }

    /**
     * 绑定事件
     */
    bindEvents() {
        // 文件上传
        this.elements.bookUpload.addEventListener('change', (e) => this.handleBookUpload(e));
        this.elements.musicUpload.addEventListener('change', (e) => this.handleMusicUpload(e));
        this.elements.startReading.addEventListener('click', () => this.startReading());

        // 导航
        this.elements.prevPage.addEventListener('click', () => this.prevPage());
        this.elements.nextPage.addEventListener('click', () => this.nextPage());

        // 侧边栏
        this.elements.toggleToc.addEventListener('click', () => this.toggleSidebar('toc'));
        this.elements.toggleSettings.addEventListener('click', () => this.toggleSidebar('settings'));
        this.elements.closeToc.addEventListener('click', () => this.closeSidebars());
        this.elements.closeSettings.addEventListener('click', () => this.closeSidebars());

        // 设置
        this.elements.fontSizeSlider.addEventListener('input', (e) => this.changeFontSize(e.target.value));
        this.elements.themeButtons.forEach(btn => {
            btn.addEventListener('click', () => this.changeTheme(btn.dataset.theme));
        });
        this.elements.toggleMusic.addEventListener('click', () => this.toggleMusic());
        this.elements.volumeSlider.addEventListener('input', (e) => this.changeVolume(e.target.value));
        this.elements.clearData.addEventListener('click', () => this.clearAllData());

        // 点击遮罩关闭侧边栏
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('overlay')) {
                this.closeSidebars();
            }
        });

        // 键盘导航
        document.addEventListener('keydown', (e) => {
            if (this.elements.readerScreen.classList.contains('active')) {
                if (e.key === 'ArrowLeft') this.prevPage();
                if (e.key === 'ArrowRight') this.nextPage();
            }
        });

        // 窗口大小改变时重新分页
        window.addEventListener('resize', () => {
            if (this.state.chapters.length > 0) {
                this.calculatePages();
                this.renderPage();
            }
        });
    }

    /**
     * 处理小说文件上传
     */
    handleBookUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            const content = e.target.result;
            this.state.bookName = file.name.replace('.txt', '');
            this.state.chapters = this.parseChapters(content);
            
            // 更新 UI
            const label = this.elements.bookUpload.previousElementSibling;
            label.classList.add('has-file');
            label.querySelector('span:last-child').textContent = `已选择: ${file.name}`;
            
            this.elements.startReading.disabled = false;
        };
        reader.readAsText(file, 'UTF-8');
    }

    /**
     * 处理音乐文件上传
     */
    handleMusicUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

        this.state.musicFile = URL.createObjectURL(file);
        this.elements.bgmPlayer.src = this.state.musicFile;
        
        // 更新 UI
        const label = this.elements.musicUpload.previousElementSibling;
        label.classList.add('has-file');
        label.querySelector('span:last-child').textContent = `已选择: ${file.name}`;
    }

    /**
     * 解析章节
     * 支持多种章节格式：第X章、Chapter X、X、第一章 等
     */
    parseChapters(content) {
        // 章节匹配模式
        const patterns = [
            /^(第[一二三四五六七八九十百千万零\d]+章[\s:：]+[^\n]*)/m,  // 第X章 标题
            /^(Chapter\s+\d+[\s:：]+[^\n]*)/mi,  // Chapter X Title
            /^(\d+[\s:：]+[^\n]{0,30})/m,  // 数字标题
            /^(正文[\s:：]+[^\n]*)/m,  // 正文
            /^(前言|楔子|序章|后记|尾声)/m  // 特殊章节
        ];

        const chapters = [];
        let currentChapter = { title: '开始', content: '' };
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line) continue;

            // 检查是否是章节标题
            let isChapter = false;
            for (const pattern of patterns) {
                if (pattern.test(line)) {
                    // 保存前一章节
                    if (currentChapter.content.trim()) {
                        chapters.push({ ...currentChapter });
                    }
                    // 开始新章节
                    currentChapter = { title: line, content: '' };
                    isChapter = true;
                    break;
                }
            }

            if (!isChapter) {
                currentChapter.content += line + '\n';
            }
        }

        // 保存最后一章
        if (currentChapter.content.trim()) {
            chapters.push(currentChapter);
        }

        // 如果没有识别到章节，整本书作为一章
        if (chapters.length === 0) {
            chapters.push({ title: this.state.bookName || '全文', content: content });
        }

        return chapters;
    }

    /**
     * 开始阅读
     */
    startReading() {
        if (this.state.chapters.length === 0) return;

        // 切换屏幕
        this.elements.welcomeScreen.classList.remove('active');
        this.elements.readerScreen.classList.add('active');

        // 设置标题
        this.elements.bookTitle.textContent = this.state.bookName || '未命名书籍';

        // 生成目录
        this.renderToc();

        // 计算分页
        this.calculatePages();

        // 尝试恢复阅读进度
        const saved = this.loadProgress();
        if (saved && saved.bookName === this.state.bookName) {
            this.state.currentChapter = saved.currentChapter;
            this.state.currentPage = saved.currentPage;
        } else {
            this.state.currentChapter = 0;
            this.state.currentPage = 0;
        }

        // 渲染页面
        this.renderPage();

        // 自动播放音乐（如果有）
        if (this.state.musicFile && !this.state.isMusicPlaying) {
            this.toggleMusic();
        }
    }

    /**
     * 计算每个章节的分页
     */
    calculatePages() {
        this.state.pagesPerChapter = [];
        
        // 临时容器计算分页
        const tempDiv = document.createElement('div');
        tempDiv.style.cssText = `
            position: absolute;
            visibility: hidden;
            width: ${this.elements.contentArea.clientWidth}px;
            height: ${this.elements.contentArea.clientHeight}px;
            font-size: ${this.state.fontSize}px;
            line-height: 1.8;
            padding: 0 10px;
            overflow: hidden;
        `;
        document.body.appendChild(tempDiv);

        this.state.chapters.forEach(chapter => {
            tempDiv.innerHTML = this.formatContent(chapter.content);
            const pages = Math.ceil(tempDiv.scrollHeight / tempDiv.clientHeight);
            this.state.pagesPerChapter.push(Math.max(1, pages));
        });

        document.body.removeChild(tempDiv);
    }

    /**
     * 格式化内容
     */
    formatContent(content) {
        return content
            .split('\n')
            .map(p => p.trim() ? `<p>${p}</p>` : '')
            .join('');
    }

    /**
     * 渲染当前页面
     */
    renderPage() {
        const chapter = this.state.chapters[this.state.currentChapter];
        if (!chapter) return;

        // 章节标题
        this.elements.chapterTitle.textContent = chapter.title;

        // 内容
        this.elements.contentArea.innerHTML = this.formatContent(chapter.content);

        // 分页滚动
        const pageHeight = this.elements.contentArea.clientHeight;
        this.elements.contentArea.scrollTop = this.state.currentPage * pageHeight;

        // 更新页码信息
        const totalPages = this.state.pagesPerChapter[this.state.currentChapter];
        this.elements.pageInfo.textContent = `第 ${this.state.currentPage + 1} 页 / 共 ${totalPages} 页`;

        // 更新按钮状态
        this.elements.prevPage.disabled = this.state.currentChapter === 0 && this.state.currentPage === 0;
        this.elements.nextPage.disabled = 
            this.state.currentChapter === this.state.chapters.length - 1 && 
            this.state.currentPage === totalPages - 1;

        // 更新进度条
        this.updateProgress();

        // 更新目录高亮
        this.updateTocHighlight();

        // 保存进度
        this.saveProgress();
    }

    /**
     * 上一页
     */
    prevPage() {
        if (this.state.currentPage > 0) {
            this.state.currentPage--;
        } else if (this.state.currentChapter > 0) {
            this.state.currentChapter--;
            this.state.currentPage = this.state.pagesPerChapter[this.state.currentChapter] - 1;
        }
        this.renderPage();
    }

    /**
     * 下一页
     */
    nextPage() {
        const totalPages = this.state.pagesPerChapter[this.state.currentChapter];
        if (this.state.currentPage < totalPages - 1) {
            this.state.currentPage++;
        } else if (this.state.currentChapter < this.state.chapters.length - 1) {
            this.state.currentChapter++;
            this.state.currentPage = 0;
        }
        this.renderPage();
    }

    /**
     * 跳转到指定章节
     */
    jumpToChapter(index) {
        if (index >= 0 && index < this.state.chapters.length) {
            this.state.currentChapter = index;
            this.state.currentPage = 0;
            this.renderPage();
            this.closeSidebars();
        }
    }

    /**
     * 渲染目录
     */
    renderToc() {
        this.elements.tocList.innerHTML = '';
        this.state.chapters.forEach((chapter, index) => {
            const item = document.createElement('div');
            item.className = 'toc-item';
            item.textContent = chapter.title;
            item.addEventListener('click', () => this.jumpToChapter(index));
            this.elements.tocList.appendChild(item);
        });
    }

    /**
     * 更新目录高亮
     */
    updateTocHighlight() {
        const items = this.elements.tocList.querySelectorAll('.toc-item');
        items.forEach((item, index) => {
            item.classList.toggle('active', index === this.state.currentChapter);
        });
    }

    /**
     * 更新进度条
     */
    updateProgress() {
        let totalPages = 0;
        let currentTotalPage = 0;

        this.state.pagesPerChapter.forEach((pages, index) => {
            totalPages += pages;
            if (index < this.state.currentChapter) {
                currentTotalPage += pages;
            }
        });
        currentTotalPage += this.state.currentPage;

        const progress = totalPages > 0 ? (currentTotalPage / totalPages) * 100 : 0;
        this.elements.progressFill.style.width = `${progress}%`;
    }

    /**
     * 切换侧边栏
     */
    toggleSidebar(type) {
        const isToc = type === 'toc';
        const target = isToc ? this.elements.tocSidebar : this.elements.settingsSidebar;
        const other = isToc ? this.elements.settingsSidebar : this.elements.tocSidebar;

        other.classList.remove('open');
        target.classList.toggle('open');

        // 添加/移除遮罩
        this.toggleOverlay(target.classList.contains('open'));
    }

    /**
     * 关闭所有侧边栏
     */
    closeSidebars() {
        this.elements.tocSidebar.classList.remove('open');
        this.elements.settingsSidebar.classList.remove('open');
        this.toggleOverlay(false);
    }

    /**
     * 切换遮罩层
     */
    toggleOverlay(show) {
        let overlay = document.querySelector('.overlay');
        if (!overlay && show) {
            overlay = document.createElement('div');
            overlay.className = 'overlay';
            document.body.appendChild(overlay);
        }
        if (overlay) {
            overlay.classList.toggle('active', show);
            if (!show) {
                setTimeout(() => overlay.remove(), 300);
            }
        }
    }

    /**
     * 改变字体大小
     */
    changeFontSize(size) {
        this.state.fontSize = parseInt(size);
        this.elements.fontSizeValue.textContent = size;
        this.elements.contentArea.style.fontSize = `${size}px`;
        this.saveSettings();
        
        // 重新计算分页
        this.calculatePages();
        this.renderPage();
    }

    /**
     * 改变主题
     */
    changeTheme(theme) {
        this.state.theme = theme;
        document.body.className = `theme-${theme}`;
        
        // 更新按钮状态
        this.elements.themeButtons.forEach(btn => {
            btn.classList.toggle('active', btn.dataset.theme === theme);
        });

        this.saveSettings();
    }

    /**
     * 切换音乐播放
     */
    toggleMusic() {
        if (!this.state.musicFile) {
            alert('请先上传音乐文件');
            return;
        }

        if (this.state.isMusicPlaying) {
            this.elements.bgmPlayer.pause();
            this.elements.toggleMusic.textContent = '▶️ 播放';
        } else {
            this.elements.bgmPlayer.play().catch(e => console.log('播放失败:', e));
            this.elements.toggleMusic.textContent = '⏸️ 暂停';
        }
        this.state.isMusicPlaying = !this.state.isMusicPlaying;
    }

    /**
     * 改变音量
     */
    changeVolume(volume) {
        this.state.musicVolume = volume / 100;
        this.elements.volumeValue.textContent = volume;
        this.elements.bgmPlayer.volume = this.state.musicVolume;
        this.saveSettings();
    }

    /**
     * 保存设置到 localStorage
     */
    saveSettings() {
        const settings = {
            fontSize: this.state.fontSize,
            theme: this.state.theme,
            musicVolume: this.state.musicVolume
        };
        localStorage.setItem('ebookReaderSettings', JSON.stringify(settings));
    }

    /**
     * 加载设置
     */
    loadSettings() {
        const saved = localStorage.getItem('ebookReaderSettings');
        if (saved) {
            const settings = JSON.parse(saved);
            this.state.fontSize = settings.fontSize || 18;
            this.state.theme = settings.theme || 'light';
            this.state.musicVolume = settings.musicVolume || 0.5;

            // 应用设置
            this.elements.fontSizeSlider.value = this.state.fontSize;
            this.elements.fontSizeValue.textContent = this.state.fontSize;
            this.changeTheme(this.state.theme);
            this.elements.volumeSlider.value = this.state.musicVolume * 100;
            this.elements.volumeValue.textContent = Math.round(this.state.musicVolume * 100);
            this.elements.bgmPlayer.volume = this.state.musicVolume;
        }
    }

    /**
     * 保存阅读进度
     */
    saveProgress() {
        const progress = {
            bookName: this.state.bookName,
            currentChapter: this.state.currentChapter,
            currentPage: this.state.currentPage,
            timestamp: Date.now()
        };
        localStorage.setItem('ebookReaderProgress', JSON.stringify(progress));
    }

    /**
     * 加载阅读进度
     */
    loadProgress() {
        const saved = localStorage.getItem('ebookReaderProgress');
        return saved ? JSON.parse(saved) : null;
    }

    /**
     * 检查是否有保存的进度
     */
    checkSavedProgress() {
        const saved = this.loadProgress();
        if (saved && saved.bookName) {
            console.log(`发现阅读进度: ${saved.bookName} - 第${saved.currentChapter + 1}章 第${saved.currentPage + 1}页`);
        }
    }

    /**
     * 清除所有数据
     */
    clearAllData() {
        if (confirm('确定要清除所有设置和阅读进度吗？此操作不可恢复。')) {
            localStorage.removeItem('ebookReaderSettings');
            localStorage.removeItem('ebookReaderProgress');
            location.reload();
        }
    }
}

// 启动应用
document.addEventListener('DOMContentLoaded', () => {
    new EbookReader();
});
