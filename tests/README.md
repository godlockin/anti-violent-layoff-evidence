# AVLE Tests / 测试框架

> **核心原则 / Core Principle**:
> - **仓库根** = skills 本身(开源给所有人用)
> - **`tests/`** = UT/IT 框架 + 本机实测结果(用于查漏补缺,**不入开源仓库**)
>
> - **Repo root** = skills themselves (open-source for everyone)
> - **`tests/`** = UT/IT framework + local machine test results (for gap analysis, **not in open-source repo**)

---

## 目录结构 / Directory Layout

```
tests/
├── README.md                       ← 你在这里
│
├── unit/                           ← 单元测试(纯函数,无 IO)
│   ├── test-holiday-sync.sh        ← 节假日同步逻辑
│   ├── test-account-classify.sh    ← git 账号分组逻辑
│   ├── test-storage-extensions.sh  ← 工作文件扩展名匹配
│   └── test-location-parser.sh     ← 位置自动探测逻辑
│
├── integration/                    ← 集成测试(端到端)
│   ├── test-launcher.sh            ← avle-launcher 完整流程
│   ├── test-unify-summarize.sh     ← case-brief 生成
│   ├── test-evidence-collector.sh  ← 收集 + 加密打包
│   └── test-rust-accel.sh          ← rust 加速器 fallback
│
├── expected/                       ← 期望输出(被测输入 → 期望输出)
│   ├── case-brief-template.md
│   ├── holiday-output-2025.txt
│   └── account-groups.json
│
├── fixtures/                       ← 测试 fixture(模拟输入)
│   ├── sample-emails/              ← (本机数据,gitignore)
│   ├── sample-git-repos/           ← (本机数据,gitignore)
│   └── sample-storage/             ← (本机数据,gitignore)
│
├── output/                         ← 本机跑出的实际输出(查漏补缺)
│   ├── YYYY-MM-DD-<your-name>/     ← (本机数据,gitignore)
│   └── ...
│
├── snapshots/                      ← 快照对比(回归测试)
│   └── (本机数据,gitignore)
│
└── local-runs/                     ← 本机运行的 logs
    └── (本机数据,gitignore)
```

---

## 跑法 / How to Run

```bash
# 1) 跑所有测试
bash tests/run-all.sh

# 2) 跑单元测试
bash tests/unit/test-holiday-sync.sh

# 3) 跑集成测试
bash tests/integration/test-launcher.sh

# 4) 跑快照对比
bash tests/snapshots/snapshot-diff.sh
```

---

## 本机实测结果归档规则 / Local Results Archiving

当你在本机跑 `bash scripts/avle-launcher.sh` 后:

```bash
# 把结果归档到 tests/output/<日期>-<你的名字>/
DATE=$(date +%Y-%m-%d)
NAME="@your-name"  # 或 $(whoami) — 公开仓库建议用占位符
RESULT_DIR="tests/output/$DATE-$NAME"
mkdir -p "$RESULT_DIR"

# 1) 复制证据包
cp -r ~/evidence/* "$RESULT_DIR/" 2>/dev/null || true

# 2) 记录运行日志
echo "Run at $DATE by $NAME" > "$RESULT_DIR/RUN.md"
echo "" >> "$RESULT_DIR/RUN.md"
echo "## 环境" >> "$RESULT_DIR/RUN.md"
uname -a >> "$RESULT_DIR/RUN.md"
bash --version >> "$RESULT_DIR/RUN.md"

# 3) 记录 perf 指标
echo "" >> "$RESULT_DIR/RUN.md"
echo "## 性能" >> "$RESULT_DIR/RUN.md"
echo "- 存储扫描耗时: X 秒" >> "$RESULT_DIR/RUN.md"
echo "- git 扫描耗时: Y 秒" >> "$RESULT_DIR/RUN.md"
echo "- 文件数: N" >> "$RESULT_DIR/RUN.md"

# 4) 查漏补缺清单
echo "" >> "$RESULT_DIR/RUN.md"
echo "## 查漏补缺" >> "$RESULT_DIR/RUN.md"
echo "- [ ] 邮件证据是否齐全" >> "$RESULT_DIR/RUN.md"
echo "- [ ] 工资/个税截图是否归档" >> "$RESULT_DIR/RUN.md"
echo "- [ ] 关键工单/项目截图是否齐全" >> "$RESULT_DIR/RUN.md"
```

---

## 隐私红线 / Privacy Red Lines

⚠️ **本机结果目录(tests/output/)绝对不上传**:
- `.gitignore` 已配 `tests/output/` 不入库
- 远程仓库(GitHub)只看到 skills 框架,看不到你的实测数据
- 你可以在本地完整 review 后,选择性把"去敏版"提交到 PR

---

## 数据流 / Data Flow

```
  ┌──────────────────┐
  │  本机跑          │
  │  bash avle-      │
  │  launcher.sh     │
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │  ~/evidence/     │  ← 自动 gitignore
  │  (本地数据)      │
  └────────┬─────────┘
           │
           │  用户手动 cp
           ▼
  ┌──────────────────┐
  │  tests/output/   │  ← 自动 gitignore
  │  <日期>-<名字>/  │     供自己查漏
  └────────┬─────────┘
           │
           │  (可选)
           ▼
  ┌──────────────────┐
  │  GitHub PR       │  ← 提交脱敏的"改进建议"
  │  (去敏版)        │     不是提交数据
  └──────────────────┘
```

---

## 维护 / Maintenance

- **半年一次**:清理 `tests/output/` 旧数据(避免占空间)
- **每次大改**:跑 `bash tests/run-all.sh`,确保没退化
- **新功能**:加新 `tests/unit/test-*.sh`

---

**Maintained by**: `@test-maintainer`
