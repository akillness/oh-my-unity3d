# ONNX Export Guide for Unity Sentis / Unity AI Inference

Sentis documentation now notes that the product is renamed to *Inference Engine*. Existing `Unity.Sentis` projects remain common, so export guidance should be written to preserve both the current runtime API and the migration path in documentation.

## Export from PyTorch

```python
import torch
import torch.nn as nn

class NPCBrain(nn.Module):
    def __init__(self, obs_size: int, action_size: int):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(obs_size, 128),
            nn.ReLU(),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, action_size),
        )

    def forward(self, x):
        return self.net(x)

model = NPCBrain(obs_size=10, action_size=4)
model.eval()

dummy_input = torch.zeros(1, 10)
torch.onnx.export(
    model,
    dummy_input,
    "npc_brain.onnx",
    opset_version=17,
    input_names=["observations"],
    output_names=["actions"],
    dynamic_axes={"observations": {0: "batch_size"}},
)
```

## Export from Unity ML-Agents

After training:

```bash
mlagents-learn config/trainer.yaml --run-id=my_npc --train
# Trained model saved to: results/my_npc/NPCBrain.onnx
```

Keep the ML-Agents `Behavior Name` aligned with the runtime model contract. Copy `NPCBrain.onnx` to Unity `Assets/Models/`.

## Export from scikit-learn (using skl2onnx)

```python
from sklearn.ensemble import RandomForestClassifier
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

clf = RandomForestClassifier(n_estimators=10)
clf.fit(X_train, y_train)

initial_type = [("float_input", FloatTensorType([None, X_train.shape[1]]))]
onnx_model = convert_sklearn(clf, initial_types=initial_type, target_opset=17)

with open("classifier.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())
```

## Verify ONNX model

```python
import onnx
model = onnx.load("npc_brain.onnx")
onnx.checker.check_model(model)
print("Model is valid!")

# Check input/output shapes
for inp in model.graph.input:
    print(f"Input: {inp.name}")
for out in model.graph.output:
    print(f"Output: {out.name}")
```

## Sentis compatibility checklist

- [ ] opset_version = 17
- [ ] Input/output names are stable and easy to map in C#
- [ ] Runtime observation shape matches training-time shape
- [ ] Unsupported operators checked before Unity integration
- [ ] First-run warmup strategy decided for editor and production startup
