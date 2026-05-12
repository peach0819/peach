package com.peach.sqlformat.action;

import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.CommonDataKeys;
import com.intellij.openapi.command.WriteCommandAction;
import com.intellij.openapi.editor.Document;
import com.intellij.openapi.editor.Editor;
import com.intellij.openapi.editor.SelectionModel;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.Messages;
import com.intellij.openapi.vfs.VirtualFile;
import com.peach.sqlformat.engine.SqlFormatter;
import com.peach.sqlformat.engine.SqlTokenizer;
import org.jetbrains.annotations.NotNull;

public class DataWorksSqlFormatAction extends AnAction {

    private static final String SQL_EXTENSION = ".sql";

    @Override
    public void update(@NotNull AnActionEvent e) {
        // Only enable for .sql files
        VirtualFile file = e.getData(CommonDataKeys.VIRTUAL_FILE);
        boolean isSqlFile = file != null && file.getName().endsWith(SQL_EXTENSION);

        // Also require an active editor
        Editor editor = e.getData(CommonDataKeys.EDITOR);
        boolean enabled = isSqlFile && editor != null;

        e.getPresentation().setEnabledAndVisible(enabled);
    }

    @Override
    public void actionPerformed(@NotNull AnActionEvent e) {
        Editor editor = e.getRequiredData(CommonDataKeys.EDITOR);
        Project project = e.getRequiredData(CommonDataKeys.PROJECT);
        Document document = editor.getDocument();

        SelectionModel selectionModel = editor.getSelectionModel();
        String selectedText = selectionModel.getSelectedText();

        String sqlToFormat;
        int startOffset = 0;
        int endOffset = document.getTextLength();

        if (selectedText != null && !selectedText.isBlank()) {
            // Format only the selected text
            sqlToFormat = selectedText;
            startOffset = selectionModel.getSelectionStart();
            endOffset = selectionModel.getSelectionEnd();
        } else {
            // Format the entire file
            sqlToFormat = document.getText();
        }

        if (sqlToFormat.isBlank()) {
            return;
        }

        String formatted;
        try {
            SqlTokenizer tokenizer = new SqlTokenizer(sqlToFormat);
            SqlFormatter formatter = new SqlFormatter(tokenizer);
            formatted = formatter.format(sqlToFormat);
        } catch (Exception ex) {
            Messages.showErrorDialog(project,
                    "SQL格式化失败: " + ex.getMessage(),
                    "DataWorks SQL Format");
            return;
        }

        if (formatted.equals(sqlToFormat)) {
            return; // No changes needed
        }

        int finalStartOffset = startOffset;
        int finalEndOffset = endOffset;
        String finalFormatted = formatted;
        WriteCommandAction.runWriteCommandAction(project, () -> {
            document.replaceString(finalStartOffset, finalEndOffset, finalFormatted);
            // Clear selection
            selectionModel.removeSelection();
        });
    }
}
