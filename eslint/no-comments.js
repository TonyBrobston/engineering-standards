const allowedCommentPatterns = [
  /^\s*eslint-(disable|enable)/,
  /^\s*@ts-expect-error/,
  /^\s*\/ <reference /,
  /^\s*(global|globals) /,
  /^\s*@jsx/,
  /^\s*#!/,
  /^\s*SPDX-License-Identifier/,
];

function isAllowedComment(comment) {
  return allowedCommentPatterns.some((pattern) => pattern.test(comment.value));
}

export const noCommentsRule = {
  meta: {
    type: "problem",
    docs: {
      description:
        "Disallow comments. Express the idea with a name or an extracted function instead.",
    },
    messages: {
      comment:
        "Comments are not allowed. Extract the block into a function whose name says this, or rename the identifier. Allowed exceptions: eslint directives, @ts-expect-error, triple-slash references, license identifiers.",
    },
    schema: [],
  },
  create(context) {
    return {
      Program() {
        for (const comment of context.sourceCode.getAllComments()) {
          if (isAllowedComment(comment)) {
            continue;
          }
          context.report({ loc: comment.loc, messageId: "comment" });
        }
      },
    };
  },
};

export const brobstonPlugin = {
  meta: { name: "brobston", version: "1.0.0" },
  rules: { "no-comments": noCommentsRule },
};
