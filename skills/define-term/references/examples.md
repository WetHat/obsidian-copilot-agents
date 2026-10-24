# Examples

Worked requests with their exact output for each `outputFormat`. Every output cites 2–3 inspected sources with at least one external; the links below were reachable when written.

## Plain — RAM, `standard`, no configured material

- Request: `term="RAM"`, `detailMode="standard"`, no configured material.
- Output:

```markdown
==RAM (Random Access Memory)== is a computer's short-term working memory: the area that holds the data and instructions currently in use.

It matters because every running program passes through it, and its size sets how much work a machine can keep open at once. Usage is descriptive — "16 GB of RAM" names capacity, not storage; assumption: most common definition.

🔹 [RAM definition — TechTarget](https://www.techtarget.com/it-infrastructure/definition/RAM-random-access-memory) 🔹 [Random-access memory — Wikipedia](https://en.wikipedia.org/wiki/Random-access_memory)
```

## Footnote — root, from a vault excerpt

- Request: `term="root"`, `outputFormat="footnote"`, configured excerpt from `Inbox/Skillification Tasks.md` line 13: `vault-root`.
- Output:

The marker `[^root]` is inserted immediately after the occurrence; the definition below is appended at the end of the note.

```markdown
[^root]: ==root== — the top-level folder of the vault: the directory that contains all other notes and folders and against which every other path is resolved.  
    🔹 [[Skillification Tasks]] 🔹 [Root directory — Wikipedia](https://en.wikipedia.org/wiki/Root_directory)
```

## Footnote — Machine Learning, `comprehensive`

- Request: `term="Machine Learning"`, `outputFormat="footnote"`, `detailMode="comprehensive"`, configured note `ML Notes`.
- Output:

The marker `[^machinelearning]` is inserted immediately after the occurrence; the definition below is appended at the end of the note. The list stays inside the definition because every continuation line is indented four spaces and no blank line separates the blocks.

```markdown
[^machinelearning]: ==Machine Learning (ML)== — a field of computer science focused on creating algorithms that enable systems to learn patterns from data and make predictions or decisions without being explicitly programmed.
    It works by training models on examples so they generalize to new, unseen inputs. Typical uses include classification, regression, recommendation, anomaly detection, and pattern recognition.
    - Training fits model parameters to labeled examples.
    - Inference applies the fitted model to new inputs.
    - Generalization measures performance on data the model has not seen.
    Related terms: deep learning, supervised learning, overfitting.  
    🔹 [[ML Notes]] 🔹 [Machine Learning Glossary — Google for Developers](https://developers.google.com/machine-learning/glossary) 🔹 [Machine Learning — Wikipedia](https://en.wikipedia.org/wiki/Machine_learning)
```

## Callout — Machine Learning, `comprehensive`

- Request: `term="Machine Learning"`, `outputFormat="callout"`, `detailMode="comprehensive"`, configured note `ML Notes`.
- Output:

```markdown
> [!def]+ Machine Learning ^machinelearning
> Machine Learning is a field of computer science focused on creating algorithms that enable systems to learn patterns from data and make predictions or decisions without being explicitly programmed.
>
> It works by training models on examples so they generalize to new, unseen inputs. Typical uses include classification, regression, recommendation, anomaly detection, and pattern recognition across vision, language, and analytics.
>
> Considerations: performance depends on data quality and representativeness more than on model choice; a model that fits its training data too closely will not generalize.
>
> Related terms: deep learning, supervised learning, overfitting.
>
> 🔹 [[ML Notes]] 🔹 [Machine Learning Glossary — Google for Developers](https://developers.google.com/machine-learning/glossary) 🔹 [Machine Learning — Wikipedia](https://en.wikipedia.org/wiki/Machine_learning)
```
