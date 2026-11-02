"""Validate delivery example bytes; this does not automate the native application."""
from pathlib import Path
import hashlib

root = Path(__file__).resolve().parent
expected = {
    "handoff-v1.txt": "30582a64089dbce40559fc844bb3b5b502dfc40cd8b15e1875598d1b4c615771",
    "handoff-v2.txt": "a85eefc3fb93ec8ada6521eb798e2406dc3ce61fa3281b5fcadd29acb1e9d367",
}
for name, digest in expected.items():
    content = (root / "samples" / name).read_bytes()
    assert hashlib.sha256(content).hexdigest() == digest, name
    assert "原创虚构演示" in content.decode("utf-8"), name
before = (root / "samples/handoff-v1.txt").read_text()
after = (root / "samples/handoff-v2.txt").read_text()
assert "- [ ] 活动海报是否保留旧版本" in before
assert "- [x] 活动海报确定保留新版本" in after
print("两个真实导出样例的字节与修改内容一致。此检查不是应用功能自动测试。")
