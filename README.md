# Hosting and Installing Helm Charts from a GitHub Repository

Below are the organized steps in Markdown for hosting your Helm charts in a GitHub repository and making them publicly installable via GitHub Pages.

---

## 1. Clone the Helm Charts Repository

```bash
git clone https://github.com/matildacloud/helm-charts
```
---

## 2. Prepare the Chart Directories

```bash
mkdir matilda-thanos
cd matilda-thanos/
```

---

## 3. Copy Helm Chart Files

```bash
cp -r Chart.yaml templates/ values.yaml /home/matilda-svc/helm-charts/matilda-thanos/

cp -r Chart.lock charts Chart.yaml README.md templates/ values_opti.yml /root/helm-charts/matilda-prometheus/
```

---

## 4. Package Helm Charts

```bash
helm package matilda-prometheus/
helm package matilda-thanos/
```

---

## 5. Commit and Push Changes to GitHub

```bash
git add .
git commit -m "initial files upload"
git push -u origin main
```

---

## 6. Generate/Update the Helm Repository Index

```bash
helm repo index . --url https://matildacloud.github.io/helm-charts/
```

---

## 7. Enable GitHub Pages

- Go to your GitHub repository's **Settings** tab.
- In the **Pages** section:
  - Set the **Source** branch to `main`
  - Set the folder to `/root` (or appropriate folder like `/docs` or use a `gh-pages` branch)
- Save the settings

GitHub Pages will now host your Helm repository at:  
**https://matildacloud.github.io/helm-charts/**

---

## 8. Verify and Install Charts from the Public Helm Repository

```bash
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update
helm search repo matilda
helm install thanos-release matilda/matilda-thanos
helm install prometheus-release matilda/prometheus
```

