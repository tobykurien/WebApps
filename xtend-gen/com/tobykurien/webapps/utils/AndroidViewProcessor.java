package com.tobykurien.webapps.utils;

import org.eclipse.xtend.lib.macro.AbstractFieldProcessor;
import org.eclipse.xtend.lib.macro.TransformationContext;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext;
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration;
import org.eclipse.xtend.lib.macro.declaration.TypeReference;
import org.eclipse.xtend.lib.macro.declaration.Visibility;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class AndroidViewProcessor extends AbstractFieldProcessor {
  public void doTransform(final MutableFieldDeclaration field, @Extension final TransformationContext context) {
    MutableTypeDeclaration _declaringType = field.getDeclaringType();
    String _simpleName = field.getSimpleName();
    String _plus = ("_init_" + _simpleName);
    final Procedure1<MutableMethodDeclaration> _function = new Procedure1<MutableMethodDeclaration>() {
        public void apply(final MutableMethodDeclaration it) {
          it.setVisibility(Visibility.PRIVATE);
          TypeReference _type = field.getType();
          it.setReturnType(_type);
          final String rclass = "com.tobykurien.webapps.R";
          final CompilationStrategy _function = new CompilationStrategy() {
              public CharSequence compile(final CompilationContext it) {
                StringConcatenation _builder = new StringConcatenation();
                _builder.append("return (");
                TypeReference _type = field.getType();
                _builder.append(_type, "");
                _builder.append(") findViewById(");
                _builder.append(rclass, "");
                _builder.append(".id.");
                String _simpleName = field.getSimpleName();
                _builder.append(_simpleName, "");
                _builder.append(");");
                _builder.newLineIfNotEmpty();
                return _builder;
              }
            };
          it.setBody(_function);
        }
      };
    _declaringType.addMethod(_plus, _function);
    MutableTypeDeclaration _declaringType_1 = field.getDeclaringType();
    String _simpleName_1 = field.getSimpleName();
    String _plus_1 = ("get_" + _simpleName_1);
    final Procedure1<MutableMethodDeclaration> _function_1 = new Procedure1<MutableMethodDeclaration>() {
        public void apply(final MutableMethodDeclaration it) {
          TypeReference _type = field.getType();
          it.setReturnType(_type);
          final CompilationStrategy _function = new CompilationStrategy() {
              public CharSequence compile(final CompilationContext it) {
                StringConcatenation _builder = new StringConcatenation();
                _builder.append("if (");
                String _simpleName = field.getSimpleName();
                _builder.append(_simpleName, "");
                _builder.append("==null)");
                _builder.newLineIfNotEmpty();
                String _simpleName_1 = field.getSimpleName();
                _builder.append(_simpleName_1, "");
                _builder.append(" = _init_");
                String _simpleName_2 = field.getSimpleName();
                _builder.append(_simpleName_2, "");
                _builder.append("();");
                _builder.newLineIfNotEmpty();
                _builder.append("return ");
                String _simpleName_3 = field.getSimpleName();
                _builder.append(_simpleName_3, "");
                _builder.append(";");
                _builder.newLineIfNotEmpty();
                return _builder;
              }
            };
          it.setBody(_function);
        }
      };
    _declaringType_1.addMethod(_plus_1, _function_1);
  }
}
