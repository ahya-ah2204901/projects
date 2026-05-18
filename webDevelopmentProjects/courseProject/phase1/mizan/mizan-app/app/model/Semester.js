export default class Semester {
  constructor({ id, label }) {
    this.id = id;
    this.label = label;
  }

  // static method to generate Semester from current date
  static getCurrentSem() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;

    const codes = [
      { code: "sp", label: "Spring", start: 1, end: 5 },
      { code: "su", label: "Summer", start: 6, end: 7 },
      { code: "fa", label: "Fall", start: 8, end: 12 },
    ];

    const match = codes.find((c) => month >= c.start && month <= c.end);

    if (!match) throw new Error("Invalid month");

    const yrLabel = String(year);
    return new Semester({
      id: `${match.code}${yrLabel.substring(2, 4)}`,
      label: `${match.label} ${yrLabel}`,
    });
  }
}

// Assumptions for simplicity:
// 1 -> 5 = Spring
// 6 -> 7 = Summer
// 8 -> 12 = Fall
