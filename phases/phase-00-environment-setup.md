# Phase 0: 環境準備

**所要時間**: 10分  
**難易度**: ⭐  

[← 目次に戻る](../README.md)

---

## 📚 学習ポイント

- Docker / Docker Composeの確認
- 作業ディレクトリの準備

---

## Task 0-1: 必要なツールの確認

```bash
# Dockerバージョン確認
docker --version
# Docker version 20.10 以上

# Docker Composeバージョン確認
docker compose version
# Docker Compose version v2.0 以上

# Gitバージョン確認
git --version
```

✅ **確認ポイント**:
- Docker Desktop がインストールされていること
- Docker が起動していること

---

## Task 0-2: プロジェクトディレクトリ作成

```bash
cd ~/Documents/Books/PerfectRoR/hands-on
mkdir book_event
cd book_event
```

または、既にディレクトリがある場合:

```bash
cd ~/Documents/Books/PerfectRoR/hands-on/book_event
```

---

## ✅ Phase 0 完了チェック

- [ ] Dockerがインストールされている（`docker --version`で確認）
- [ ] Docker Composeが使える（`docker compose version`で確認）
- [ ] Gitがインストールされている（`git --version`で確認）
- [ ] プロジェクトディレクトリに移動した（`pwd`で確認）

---

## 🎯 次のステップ

環境準備が完了しました！次は **[Phase 1: Docker環境構築](phase-01-docker-setup.md)** に進みましょう。

[← 目次に戻る](../README.md) | [Phase 1: Docker環境構築 →](phase-01-docker-setup.md)
