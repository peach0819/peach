package com.peach.sqlformat.gui;

import com.peach.sqlformat.engine.SqlFormatter;
import com.peach.sqlformat.engine.SqlTokenizer;

import javax.swing.*;
import java.awt.*;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.awt.event.KeyEvent;

public class SqlFormatGui extends JFrame {

    private final JTextArea inputArea;
    private final JTextArea outputArea;

    public SqlFormatGui() {
        setTitle("SQL\u683C\u5F0F\u5316\u5DE5\u5177");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(900, 700);
        setLocationRelativeTo(null);

        // Main panel
        JPanel mainPanel = new JPanel(new GridBagLayout());
        mainPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.BOTH;

        // ===== Input section =====
        c.gridx = 0;
        c.gridy = 0;
        c.weightx = 1.0;
        c.weighty = 0.0;
        c.insets = new Insets(0, 0, 5, 0);
        JLabel inputLabel = new JLabel("\u8F93\u5165SQL:");
        inputLabel.setFont(new Font("\u5FAE\u8F6F\u96C5\u9ED1", Font.PLAIN, 13));
        mainPanel.add(inputLabel, c);

        c.gridy = 1;
        c.weighty = 1.0;
        c.insets = new Insets(0, 0, 10, 0);
        inputArea = new JTextArea();
        inputArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        inputArea.setTabSize(4);
        inputArea.setLineWrap(false);
        JScrollPane inputScroll = new JScrollPane(inputArea);
        inputScroll.setBorder(BorderFactory.createLineBorder(new Color(200, 200, 200)));
        mainPanel.add(inputScroll, c);

        // ===== Format button =====
        c.gridy = 2;
        c.weighty = 0.0;
        c.insets = new Insets(0, 0, 10, 0);
        JButton formatButton = new JButton("\u683C\u5F0F\u5316");
        formatButton.setFont(new Font("\u5FAE\u8F6F\u96C5\u9ED1", Font.BOLD, 14));
        formatButton.setPreferredSize(new Dimension(120, 36));
        formatButton.setForeground(Color.BLACK);
        formatButton.setFocusPainted(false);
        formatButton.setBorder(BorderFactory.createEmptyBorder(5, 20, 5, 20));
        formatButton.addActionListener(e -> formatSql());

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
        buttonPanel.add(formatButton);
        mainPanel.add(buttonPanel, c);

        // Ctrl+Enter shortcut to format
        inputArea.getInputMap(JComponent.WHEN_FOCUSED).put(
                KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, KeyEvent.CTRL_DOWN_MASK), "format");
        inputArea.getActionMap().put("format", new AbstractAction() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent e) {
                formatSql();
            }
        });

        // ===== Output section =====
        c.gridy = 3;
        c.weighty = 0.0;
        c.insets = new Insets(0, 0, 5, 0);
        JPanel outputHeader = new JPanel(new BorderLayout());
        JLabel outputLabel = new JLabel("\u683C\u5F0F\u5316\u7ED3\u679C:");
        outputLabel.setFont(new Font("\u5FAE\u8F6F\u96C5\u9ED1", Font.PLAIN, 13));
        outputHeader.add(outputLabel, BorderLayout.WEST);

        JButton copyButton = new JButton("\u590D\u5236");
        copyButton.setFont(new Font("\u5FAE\u8F6F\u96C5\u9ED1", Font.PLAIN, 12));
        copyButton.addActionListener(e -> copyToClipboard());
        outputHeader.add(copyButton, BorderLayout.EAST);

        mainPanel.add(outputHeader, c);

        c.gridy = 4;
        c.weighty = 1.0;
        c.insets = new Insets(0, 0, 0, 0);
        outputArea = new JTextArea();
        outputArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        outputArea.setTabSize(4);
        outputArea.setEditable(false);
        outputArea.setLineWrap(false);
        outputArea.setBackground(new Color(245, 245, 245));
        JScrollPane outputScroll = new JScrollPane(outputArea);
        outputScroll.setBorder(BorderFactory.createLineBorder(new Color(200, 200, 200)));
        mainPanel.add(outputScroll, c);

        add(mainPanel);
    }

    private void formatSql() {
        String input = inputArea.getText();
        if (input == null || input.trim().isEmpty()) {
            JOptionPane.showMessageDialog(this,
                    "\u8BF7\u8F93\u5165SQL\u4EE3\u7801",
                    "\u63D0\u793A",
                    JOptionPane.WARNING_MESSAGE);
            return;
        }

        try {
            SqlTokenizer tokenizer = new SqlTokenizer(input);
            SqlFormatter formatter = new SqlFormatter(tokenizer);
            String formatted = formatter.format(input);
            outputArea.setText(formatted);

            // Auto-scroll to top
            SwingUtilities.invokeLater(() -> {
                outputArea.setCaretPosition(0);
            });
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this,
                    "\u683C\u5F0F\u5316\u51FA\u9519: " + ex.getMessage(),
                    "\u9519\u8BEF",
                    JOptionPane.ERROR_MESSAGE);
            ex.printStackTrace();
        }
    }

    private void copyToClipboard() {
        String text = outputArea.getText();
        if (text == null || text.isEmpty()) {
            JOptionPane.showMessageDialog(this,
                    "\u6CA1\u6709\u53EF\u590D\u5236\u7684\u5185\u5BB9",
                    "\u63D0\u793A",
                    JOptionPane.WARNING_MESSAGE);
            return;
        }

        StringSelection selection = new StringSelection(text);
        Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
        clipboard.setContents(selection, null);

        JOptionPane.showMessageDialog(this,
                "\u5DF2\u590D\u5236\u5230\u526A\u8D34\u677F",
                "\u63D0\u793A",
                JOptionPane.INFORMATION_MESSAGE);
    }

    public static void main(String[] args) {
        try {
            // Use Windows native look
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            // Fall back to default
        }

        SwingUtilities.invokeLater(() -> {
            SqlFormatGui gui = new SqlFormatGui();
            gui.setVisible(true);
        });
    }
}
